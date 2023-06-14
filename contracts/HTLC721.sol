// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HTLC721 is Ownable{

    // HTLC lock data structure
    struct HTLCLock {
        address sender;                     // sender of the asset
        address receiver;                   // receiver of the asset
        address erc721Contract;             // erc-721 token contract address
        uint256 erc721TokenID;              // asset (erc-721 token) id
        bytes32 hashLock;                   // hash lock
        uint256 timeLock;                   // time lock
        bool withdrawn;                     // whether asset been withdrawn
        bool refunded;                      // whether asset been refunded
        bytes32 preimage;                   // preimage of the hash lock
    }

    // HTLC locks
    mapping (bytes32 => HTLCLock) private _locks;
    
    // events
    event NewHTLC721Transaction(
        bytes32 indexed transactionID,      // htlc transaction id
        address indexed sender,             // sender of the asset
        address indexed receiver,           // receiver of the asset
        address erc721Contract,             // erc-721 token contract address
        uint256 erc721TokenID,              // asset (erc-721 token) id
        bytes32 hashLock,                   // hash lock
        uint256 timeLock                    // time lock
    );
    event HTLC721Withdrawn(bytes32 indexed transactionID);
    event HTLC721Refunded(bytes32 indexed transactionID);

    // modifiers
    modifier assetTransferable(address erc721Contract, uint256 erc721TokenID){
        // ensure HTLC contract is approved to transfer target erc721 token
        require(ERC721(erc721Contract).getApproved(erc721TokenID)==address(this), 
        "target asset cannot be transfered until HTLC being approved");
        _;
    }

    modifier futureTimeLock(uint256 timeLock){
        // ensure time lock is later than last blocktime (now)
        require(timeLock > block.timestamp, 
        "time lock should be later than last blocktime");
        _;
    }

    modifier transactionExists(bytes32 transactionID) {
        // ensure HTLC transaction exists
        require(_haveContract(transactionID), 
        "HTLC transaction does not exist");
        _;
    }

    modifier hashLockMatches(bytes32 transactionID, bytes32 preimage){
        // ensure input secret(preimage) matches the hash lock
        require(_locks[transactionID].hashLock == sha256(abi.encodePacked(preimage)),
        "HTLC hash lock does not match");
        _;
    }

    modifier withdrawable(bytes32 transactionID){
        // sanity check on whether asset is withdrawable
        require(_locks[transactionID].receiver == msg.sender,
        "current user is not the asset receiver");
        require(_locks[transactionID].withdrawn == false,
        "the asset has been withdrawn");
        require(_locks[transactionID].timeLock > block.timestamp,
        "exceed the HTLC lock time");
        _;
    }

    modifier refundable(bytes32 transactionID){
        // sanity check on whether asset is refundable
        require(_locks[transactionID].sender == msg.sender,
        "current user is not the asset sender");
        require(_locks[transactionID].refunded == false,
        "the asset has been refunded");
        require(_locks[transactionID].withdrawn == false,
        "the asset has been withdrawn");
        require(_locks[transactionID].timeLock <= block.timestamp,
        "should exceed the HTLC lock time");
        _;
    }

    // external functions

    /**
     * @dev create a new HTLC transaction
     * @param receiver asset receiver
     * @param hashLock hash lock
     * @param timeLock time lock
     * @param erc721Contract erc-721 token contract address
     * @param erc721TokenID asset (erc-721 token) id
     * @return transactionID the created HTLC transaction ID
     */
    function newHTLC721Transaction(
        address receiver, 
        bytes32 hashLock, 
        uint256 timeLock, 
        address erc721Contract, 
        uint256 erc721TokenID
        ) external 
        assetTransferable(erc721Contract, erc721TokenID) 
        futureTimeLock(timeLock)
        returns(bytes32 transactionID){
            transactionID = sha256(abi.encodePacked(msg.sender, receiver, erc721Contract, erc721TokenID, hashLock, timeLock));
            if (_haveContract(transactionID)) revert("transaction already exists");
            ERC721(erc721Contract).transferFrom(msg.sender, address(this), erc721TokenID);
            _locks[transactionID] = HTLCLock(msg.sender, receiver, erc721Contract, erc721TokenID, hashLock, timeLock, false, false, 0x0);
            emit NewHTLC721Transaction(transactionID, msg.sender, receiver, erc721Contract, erc721TokenID, hashLock, timeLock);
    }

    /**
     * @dev receiver withdraw the locked asset before time exceeds the time lock
     * @param transactionID HTLC transaction ID
     * @param preimage the secret
     * @return boolean indicates a successful withdrawal
     */
    function withdraw(
        bytes32 transactionID, 
        bytes32 preimage
        ) external 
        transactionExists(transactionID) 
        hashLockMatches(transactionID, preimage) 
        withdrawable(transactionID)
        returns(bool){
        HTLCLock storage lock = _locks[transactionID];
        lock.preimage = preimage;
        lock.withdrawn = true;
        ERC721(lock.erc721Contract).transferFrom(address(this), lock.receiver, lock.erc721TokenID);
        emit HTLC721Withdrawn(transactionID);
        return true;
    }

    /**
     * @dev sender refund the locked asset after time exceeds the time lock
     * @param transactionID HTLC transaction ID
     * @return boolean indicates a successful refund
     */
    function refund(
        bytes32 transactionID
        ) external 
        transactionExists(transactionID) 
        refundable(transactionID) 
        returns(bool){
        HTLCLock storage lock = _locks[transactionID];
        lock.refunded = true;
        ERC721(lock.erc721Contract).transferFrom(address(this), lock.sender, lock.erc721TokenID);
        emit HTLC721Refunded(transactionID);
        return true;
    }

    // functions for dev

    /**
     * @dev (for dev use) get the detailed HTLC transaction information
     * @param transactionID HTLC transaction ID
     */
    function getHTLC(bytes32 transactionID) public view onlyOwner returns(
        address sender,                     // sender of the asset
        address receiver,                   // receiver of the asset
        address erc721Contract,             // erc-721 token contract address
        uint256 erc721TokenID,              // asset (erc-721 token) id
        bytes32 hashLock,                   // hash lock
        uint256 timeLock,                   // time lock
        bool withdrawn,                     // whether asset been withdrawn
        bool refunded,                      // whether asset been refunded
        bytes32 preimage                    // preimage of the hash lock
    ){
        if (!_haveContract(transactionID)) return (address(0), address(0), address(0), 0, 0, 0, false, false, 0);
        HTLCLock storage lock = _locks[transactionID];
        return (
            lock.sender,
            lock.receiver,
            lock.erc721Contract,
            lock.erc721TokenID,
            lock.hashLock,
            lock.timeLock,
            lock.withdrawn,
            lock.refunded,
            lock.preimage
        );
    }

    /**
     * @dev (for dev use) get current block time
     * @return time current block time
     */
    function getCurrentBlockTime() public view onlyOwner returns(uint256 time){
        return block.timestamp;
    }

    /**
     * @dev (for dev use) get the hash lock of the preimage
     * @param preimage the preimage
     * @return hashLock the encoded hashing of the preimage
     */
    function getHashLock(bytes32 preimage) public view onlyOwner returns(bytes32 hashLock){
        hashLock = sha256(abi.encodePacked(preimage));
    }

    // internal utils
    function _haveContract(bytes32 transactionID) internal view returns (bool exists) {
        exists = (_locks[transactionID].sender != address(0));
    }

}