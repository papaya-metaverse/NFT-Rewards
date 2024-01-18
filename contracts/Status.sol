// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./abstract/NFTSigVerifier.sol";

contract Status is ERC721, Ownable, NFTSigVerifier {
    event Upgrade(uint256 indexed tokenId, uint256 level);

    bool private _paused;

    mapping(uint256 tokenId => uint256 level) public level;

    constructor(
        string memory name_, 
        string memory symbol_, 
        address protocolSigner_
    ) ERC721(name_, symbol_) NFTSigVerifier(protocolSigner_) {
        _paused = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function pause() external onlyOwner {
        _paused = true;
    }

    function unpause() external onlyOwner {
        _paused = false;
    }

    function safeMint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }

    function mintBySig(NFTSigVerifier.StatusMintSig calldata status, bytes memory rvs) external {
        verifyStatusMint(status, rvs);

        _safeMint(status.base.owner, status.base.tokenId);
    }

    function upgradeNFT(uint256 tokenId, uint256 level_) external onlyOwner {
        require(_exists(tokenId), "ERC721: token not minted");
        
        level[tokenId] += level_;

        emit Upgrade(tokenId, level[tokenId]);
    }

    function upgradeBySig(NFTSigVerifier.StatusUpgradeSig calldata statusUpgrade, bytes memory rvs) external {
        verifyStatusUpgrade(statusUpgrade, rvs);

        level[statusUpgrade.tokenId] += statusUpgrade.level;
        emit Upgrade(statusUpgrade.tokenId, level[statusUpgrade.tokenId]);
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        if(_paused) {
            require(from == address(0), "ERC721: transfer is paused");
        } 
    }
}
