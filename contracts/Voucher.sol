// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {SafeERC20, IERC20} from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";

contract Voucher is ERC721, Ownable {
    using SafeERC20 for IERC20;

    struct VoucherInfo {
        uint216 value;
        uint40 expirationDate;
    }

    IERC20 public token;

    mapping(uint256 tokenId => VoucherInfo) private vouchers_;
    constructor(string memory name_, string memory symbol_, IERC20 token_) ERC721(name_, symbol_) {
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

    function safeMint(address to, uint256 tokenId, VoucherInfo calldata info) external onlyOwner {
        super._safeMint(to, tokenId);
        
        vouchers_[tokenId] = info;
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
