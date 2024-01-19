// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./abstract/NFTSigVerifier.sol";

contract Status is ERC721, Ownable, NFTSigVerifier, Pausable {
    event Upgrade(uint256 indexed tokenId, uint256 level);

    mapping(uint256 tokenId => uint256 level) public level;

    constructor(
        string memory name_, 
        string memory symbol_, 
        address protocolSigner_
    ) ERC721(name_, symbol_) NFTSigVerifier(protocolSigner_) Ownable(msg.sender) {
        _pause();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }

    function mintBySig(NFTSigVerifier.StatusMintSig calldata status, bytes memory rvs) external {
        verifyStatusMint(status, rvs);

        _safeMint(status.base.owner, status.base.tokenId);
    }

    function upgradeNFT(uint256 tokenId, uint256 level_) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "ERC721: token not minted");
        
        level[tokenId] += level_;

        emit Upgrade(tokenId, level[tokenId]);
    }

    function upgradeBySig(NFTSigVerifier.StatusUpgradeSig calldata statusUpgrade, bytes memory rvs) external {
        verifyStatusUpgrade(statusUpgrade, rvs);

        level[statusUpgrade.tokenId] += statusUpgrade.level;
        emit Upgrade(statusUpgrade.tokenId, level[statusUpgrade.tokenId]);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        if(_ownerOf(tokenId) != address(0)) {
            _requireNotPaused();
        }

        super._update(to, tokenId, auth);
    }
}
