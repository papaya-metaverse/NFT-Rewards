// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NFTSigVerifier is EIP712, Ownable {
    struct NftBase {
        address owner;
        uint256 tokenId;
    }

    struct VoucherInfo {
        uint216 value;
        uint40 expirationDate;
    }

    struct StatusUpgradeSig {
        uint256 tokenId;
        uint256 level;
    }
}
