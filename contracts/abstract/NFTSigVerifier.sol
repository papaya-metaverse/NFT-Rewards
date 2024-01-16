// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NFTSigVerifier is EIP712, Ownable {
    error InvalidNonce();
    error WrongSigner();

    struct Sig {
        address signer;
        uint256 nonce;
        uint256 executionFee;
    }

    struct NftBase {
        address owner;
        uint256 tokenId;
    }

    struct VoucherInfo {
        uint216 value;
        uint40 expirationDate;
    }

    struct StatusMintSig {
        Sig sig;
        NftBase base;
    } 

    struct StatusUpgradeSig {
        Sig sig;
        uint256 tokenId;
        uint256 level;
    }

    struct VoucherSig {
        Sig sig;
        NftBase base;
        VoucherInfo info;
    }

    struct MysteryBoxSig {
        Sig sig;
        address user;
    }

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

    function _hashStatusMint(StatusMintSig calldata statusMintSig) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "StatusMintSig("
                                "Sig sig,"
                                "NftBase base"
                            ")"
                            "NftBase("
                                "address owner,"
                                "uint256 tokenId"
                            ")"
                            "Sig("
                                "address signer,"
                                "uint256 nonce,"
                                "uint256 executionFee"
                            ")"
                        ),
                        statusMintSig
                    )
                )
            );
    }

    function _hashStatusUpgrade(StatusUpgradeSig calldata statusUpgradeSig) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "StatusUpgradeSig("
                                "Sig sig,"
                                "uint256 tokenId,"
                                "uint256 level"
                            ")"
                            "Sig("
                                "address signer,"
                                "uint256 nonce,"
                                "uint256 executionFee"
                            ")"
                        ),
                        statusUpgradeSig
                    )
                )
            );
    }

    function _hashVoucher(VoucherSig calldata voucherSig) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "VoucherSig("
                                "Sig sig,"
                                "NftBase base,"
                                "VoucherInfo info"
                            ")"
                            "NftBase("
                                "address owner,"
                                "uint256 tokenId"
                            ")"
                            "Sig("
                                "address signer,"
                                "uint256 nonce,"
                                "uint256 executionFee"
                            ")"
                            "VoucherInfo("
                                "uint216 value,"
                                "uint40 expirationDate"
                            ")"
                        ),
                        voucherSig
                    )
                )
            );
    }

    function _hashMysteryBox(MysteryBoxSig calldata mysteryBoxSig) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "MysteryBoxSig("
                                "Sig sig,"
                                "address user"
                            ")"
                            "Sig("
                                "address signer,"
                                "uint256 nonce,"
                                "uint256 executionFee"
                            ")"
                        ),
                        mysteryBoxSig
                    )
                )
            );
    }

    function verifyStatusMint(StatusMintSig calldata statusMint, bytes memory rvs) internal returns (bool) {
        return _verify(
            _hashStatusMint(statusMint),
            protocolSigner,
            statusMint.sig.signer,
            statusMint.sig.nonce,
            rvs
        );
    }

    function verifyStatusUpgrade(StatusUpgradeSig calldata statusUpgrade, bytes memory rvs) internal returns (bool) {
        return _verify(
            _hashStatusUpgrade(statusUpgrade),
            protocolSigner,
            statusUpgrade.sig.signer,
            statusUpgrade.sig.nonce,
            rvs
        );
    }

    function verifyVoucher(VoucherSig calldata voucher, bytes memory rvs) internal returns (bool) {
        return _verify(
            _hashVoucher(voucher),
            protocolSigner,
            voucher.sig.signer,
            voucher.sig.nonce,
            rvs
        );
    }

    function verifyMysteryBox(MysteryBoxSig calldata mysteryBox, bytes memory rvs) internal returns (bool) {
        return _verify(
            _hashMysteryBox(mysteryBox),
            protocolSigner,
            mysteryBox.sig.signer,
            mysteryBox.sig.nonce,
            rvs
        );
    }

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
