// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Badge is ERC721Pausable, Ownable {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _pause();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) external onlyOwner {
        _safeMint(to, tokenId, data);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}
