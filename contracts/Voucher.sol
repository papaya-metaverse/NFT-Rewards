// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20, IERC20} from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";
import "./abstract/NFTSigVerifier.sol";

contract Voucher is ERC721, Ownable, NFTSigVerifier {
    using SafeERC20 for IERC20;

    IERC20 public token;

    mapping(uint256 tokenId => NFTSigVerifier.VoucherInfo) private vouchers_;
    constructor(
        string memory name_, 
        string memory symbol_, 
        IERC20 token_, 
        address protocolSigner_
    ) ERC721(name_, symbol_) NFTSigVerifier(protocolSigner_) {
        token = token_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function valueOf(uint256 tokenId) external view returns (uint256) {
        return vouchers_[tokenId].value;
    }

    function getExpirationDate(uint256 tokenId) external view returns (uint40) {
        return vouchers_[tokenId].expirationDate;
    }

    function safeMint(NftBase calldata base, VoucherInfo calldata info) external onlyOwner {
        super._safeMint(base.owner, base.tokenId);
        
        vouchers_[base.tokenId] = info;
    }

    function mintBySig(NFTSigVerifier.VoucherSig calldata voucher, bytes memory rvs) external {
        verifyVoucher(voucher, rvs);
        super._safeMint(voucher.base.owner, voucher.base.tokenId);
        
        vouchers_[voucher.base.tokenId] = voucher.info;
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        if(to == address(0)) {
            require(vouchers_[firstTokenId].expirationDate < block.timestamp, "Voucher: can`t be burned until expiration date");
        }
    }

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        if(to == address(0)) {
            token.safeTransfer(to, vouchers_[firstTokenId].value);
        }
    }

}
