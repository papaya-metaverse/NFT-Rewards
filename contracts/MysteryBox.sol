// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./abstract/NFTSigVerifier.sol";
contract MysteryBox is NFTSigVerifier, VRFConsumerBaseV2 {
    enum Types {
        VCREDITS,
        EXPERIENCE,
        VOUCHER
    }
    //Mumbai settings
    address constant vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 constant keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 40000;
    uint32 numWords = 2;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 private _subscriptionId;

    mapping(address user => mapping(Types => uint256 count)) public prizes;
    mapping(uint256 requestId => address user) private roller;

    constructor(
        address protocolSigner_,
        uint64 subscriptionId
    ) NFTSigVerifier(protocolSigner_) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        _subscriptionId = subscriptionId;
    }

    function roll(NFTSigVerifier.MysteryBoxSig calldata mysteryBox, bytes memory rvs) external {
        verifyMysteryBox(mysteryBox, rvs);
        
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            _subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        roller[requestId] = mysteryBox.user;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        if(randomWords[0] % 3 == 0) {
            prizes[roller[requestId]][Types.VCREDITS] += randomWords[1];
        } else if (randomWords[0] % 2 == 0) {
            prizes[roller[requestId]][Types.EXPERIENCE] += randomWords[1];
        } else {
            prizes[roller[requestId]][Types.VOUCHER] += randomWords[1];
        }
    }
}
