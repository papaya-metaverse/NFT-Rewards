// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
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
    ) NFTSigVerifier(protocolSigner_) VRFV2WrapperConsumerBase(linkToken, vrfWrapper) {}

    function updatePrizeInfo(Types prizeType, uint40 probability, PrizeInfo[] calldata info) external onlyOwner {
        prizeProbability[prizeType] = probability;

        delete prizeInfo[prizeType];

        for(uint i; i < info.length; i++) {
            prizeInfo[prizeType].push(info[i]);
        }
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
        if(randomWords[0] % 100 <= prizeProbability[Types.EXPERIENCE]) {
            PrizeInfo[] storage info = prizeInfo[Types.EXPERIENCE];

            for(uint i; i < prizeInfo[Types.EXPERIENCE].length; i++) {
                if(uint40(randomWords[1] % 100) < info[i].upperBound) {
                    prizes[roller[requestId]][Types.EXPERIENCE] += randomWords[1] % 100;
                    break;
                }
            }

            emit MysteryBoxOpened(roller[requestId], uint256(Types.EXPERIENCE), randomWords[1]);
        } else if (randomWords[0] % 100 <= prizeProbability[Types.VOUCHER]) {
            PrizeInfo[] storage info = prizeInfo[Types.VOUCHER];

            for(uint i; i < prizeInfo[Types.VOUCHER].length; i++) {
                if(uint40(randomWords[1] % 100) < info[i].upperBound) {
                    prizes[roller[requestId]][Types.VOUCHER] += randomWords[1] % 100;
                    break;
                }
            }

            emit MysteryBoxOpened(roller[requestId], uint256(Types.VOUCHER), randomWords[1]);
        } else {
            PrizeInfo[] storage info = prizeInfo[Types.VCREDITS];

            for(uint i; i < prizeInfo[Types.VCREDITS].length; i++) {
                if(uint40(randomWords[1] % 100) < info[i].upperBound) {
                    prizes[roller[requestId]][Types.VCREDITS] += randomWords[1] % 100;
                    break;
                }
            }

            emit MysteryBoxOpened(roller[requestId], uint256(Types.VCREDITS), randomWords[1]); 
        }
    }
}
