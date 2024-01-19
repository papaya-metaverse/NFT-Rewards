// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./abstract/NFTSigVerifier.sol";
contract MysteryBox is Ownable, NFTSigVerifier, VRFV2WrapperConsumerBase {
    enum Types {
        VCREDITS,
        EXPERIENCE,
        VOUCHER
    }

    struct PrizeInfo {
        uint40 upperBound;
        uint216 cost;
    }

    event Roll(address indexed user, uint256 requestId);
    event MysteryBoxOpened(address indexed user, uint256 rewardType, uint256 count);

    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 40000;
    uint32 numWords = 2;

    mapping(Types => uint40) public prizeProbability;
    mapping(Types => PrizeInfo[]) public prizeInfo;
    mapping(address user => mapping(Types => uint256 count)) public prizes;

    mapping(uint256 requestId => address user) private roller;

    constructor(
        address vrfWrapper,
        address linkToken,
        address protocolSigner_
    ) NFTSigVerifier(protocolSigner_) VRFV2WrapperConsumerBase(linkToken, vrfWrapper) Ownable(msg.sender) {}

    function updatePrizeInfo(Types prizeType, uint40 probability, PrizeInfo[] calldata info) external onlyOwner {
        prizeProbability[prizeType] = probability;

        prizeInfo[prizeType] = info;
    }

    function roll(NFTSigVerifier.MysteryBoxSig calldata mysteryBox, bytes memory rvs) external {
        verifyMysteryBox(mysteryBox, rvs);

        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );

        roller[requestId] = mysteryBox.user;

        emit Roll(mysteryBox.user, requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        Types prizeType;

        if(randomWords[0] % 100 <= prizeProbability[Types.EXPERIENCE]) {
            prizeType = Types.EXPERIENCE;
        } else if (randomWords[0] % 100 <= prizeProbability[Types.VOUCHER]) {
            prizeType = Types.VOUCHER;
        } else {
            prizeType = Types.VCREDITS;
        }

        PrizeInfo[] storage info = prizeInfo[prizeType];

        for(uint i; i < info.length; i++) {
            if(uint40(randomWords[1] % 100) <= info[i].upperBound) {
                prizes[roller[requestId]][prizeType] += info[i].cost;

                emit MysteryBoxOpened(roller[requestId], uint256(prizeType), info[i].cost); 

                break;
            }
        }
    }
}
