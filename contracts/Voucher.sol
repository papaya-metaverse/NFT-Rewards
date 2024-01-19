// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20, IERC20} from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";
import "./abstract/NFTSigVerifier.sol";

import "hardhat/console.sol";

contract Voucher is ERC721, Ownable, NFTSigVerifier {
    using SafeERC20 for IERC20;

    event VoucherMint(uint256 tokenId, uint256 cost);
    event VoucherBurn(address user, uint256 tokenId, uint256 cost);

    IERC20 public token;

    mapping(uint256 tokenId => NFTSigVerifier.VoucherInfo) private vouchers_;
    constructor(
        string memory name_, 
        string memory symbol_, 
        IERC20 token_, 
        address protocolSigner_
    ) ERC721(name_, symbol_) NFTSigVerifier(protocolSigner_) Ownable(msg.sender) {
        token = token_;
    }

    function updateTokenAddress(IERC20 token_) external onlyOwner {
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
        _safeMint(base.owner, base.tokenId);
        
        vouchers_[base.tokenId] = info;

        emit VoucherMint(base.tokenId, info.value);
    }

    function mintBySig(NFTSigVerifier.VoucherSig calldata voucher, bytes memory rvs) external {
        verifyVoucher(voucher, rvs);
        _safeMint(voucher.base.owner, voucher.base.tokenId);
        
        vouchers_[voucher.base.tokenId] = voucher.info;

        emit VoucherMint(voucher.base.tokenId, voucher.info.value);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        if(to == address(0)) {
            require(block.timestamp > vouchers_[tokenId].expirationDate, "Voucher: can`t be burned until expiration date");

            address from = _ownerOf(tokenId);

            super._update(to, tokenId, auth);

            delete vouchers_[tokenId];

            token.safeTransfer(from, vouchers_[tokenId].value);

            emit VoucherBurn(from, tokenId, vouchers_[tokenId].value);
        } else {
            super._update(to, tokenId, auth);
        }
    }
}
