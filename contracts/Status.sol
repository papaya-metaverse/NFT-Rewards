// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import { BySig, EIP712 } from "@1inch/solidity-utils/contracts/mixins/BySig.sol";

contract Status is ERC721, Ownable, Pausable, EIP712, BySig {
    event Upgrade(uint256 indexed tokenId, uint256 level);

    error NotSupportedFeature();

    mapping(uint256 tokenId => uint256 level) public level;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) EIP712(type(Status).name, "1") Ownable(msg.sender) {
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

    function upgradeNFT(uint256 tokenId, uint256 level_) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "ERC721: token not minted");

        level[tokenId] += level_;

        emit Upgrade(tokenId, level[tokenId]);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        if(_ownerOf(tokenId) != address(0)) {
            _requireNotPaused();
        }

        return super._update(to, tokenId, auth);
    }

    function _chargeSigner(address signer, address relayer, address token, uint256 amount, bytes calldata /* extraData */) internal override {
        revert NotSupportedFeature();
    }

    function _msgSender() internal view override(Context, BySig) returns (address) {
        return super._msgSender();
    }
}
