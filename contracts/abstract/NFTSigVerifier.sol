// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NFTSigVerifier is EIP712, Ownable {
    error InvalidNonce();

    struct Sig {
        address signer;
        uint256 nonce;
        uint256 executionFee;
    }

    // // struct PaymentSig {
    // //     Sig sig;
    // //     address receiver;
    // //     uint256 amount;
    // //     bytes32 id;
    // // }

    // struct SettingsSig {
    //     Sig sig;
    //     address user;
    //     Settings settings;
    // }

    string private constant SIGNING_DOMAIN = "NFTSigVerifier";
    string private constant SIGNATURE_VERSION = "1";

    mapping(address => uint256) public nonces;

    address protocolSigner;

    constructor(address protocolSigner_) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        protocolSigner = protocolSigner_;
    }

    function updateProtocolSigner(address protocolSigner_) external onlyOwner {
        protocolSigner = protocolSigner_;
    }

    function getChainID() external view returns (uint256) {
        return block.chainid;
    }

    // function _hashSettings(SettingsSig calldata settingssig) internal view returns (bytes32) {
    //     return
    //         _hashTypedDataV4(
    //             keccak256(
    //                 abi.encode(
    //                     keccak256(
    //                         "SettingsSig("
    //                             "Sig sig,"
    //                             "address user,"
    //                             "Settings settings"
    //                         ")"
    //                         "Settings("
    //                             "uint96 subscriptionRate,"
    //                             "uint16 userFee,"
    //                             "uint16 protocolFee,"
    //                         ")"
    //                         "Sig("
    //                             "address signer,"
    //                             "uint256 nonce,"
    //                             "uint256 executionFee"
    //                         ")"
    //                     ),
    //                     settingssig
    //                 )
    //             )
    //         );
    // }

    // function verifyUnsubscribe(UnSubSig calldata unsubscription, bytes memory rvs) internal returns (bool) {
    //     return _verify(
    //         _hashUnSubscribe(unsubscription), 
    //         unsubscription.sig.signer, 
    //         unsubscription.sig.signer, 
    //         unsubscription.sig.nonce, 
    //         rvs);
    // }

    function _verify(
        bytes32 hash,
        address signer,
        address noncer,
        uint256 nonce,
        bytes memory rvs
    ) internal returns (bool) {
        if (nonce != nonces[noncer]) {
            revert InvalidNonce();
        }

        nonces[noncer]++;

        return SignatureChecker.isValidSignatureNow(signer, hash, rvs);
    }
}
