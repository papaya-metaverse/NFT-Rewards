// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Badge is ERC721, Ownable {
    bool private _paused;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _paused = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) external onlyOwner {
        _safeMint(to, tokenId, data);
    }

    function pause() external onlyOwner {
        _paused = true;
    }

    function unpause() external onlyOwner {
        _paused = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        if(_paused) {
            require(from == address(0), "ERC721: transfer is paused");
        } 
    }

}
