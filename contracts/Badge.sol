// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract Badge is ERC721, Ownable, Pausable {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender) {
         _pause();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function safeMint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        if(_ownerOf(tokenId) != address(0)) {
            _requireNotPaused();
        }
         
        super._update(to, tokenId, auth);
    }
}
