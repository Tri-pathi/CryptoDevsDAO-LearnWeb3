// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeNFTMarketplace{
    mapping(uint256=>address) public tokens;
    uint256 nftprice=0.1 ether;

    function purchase(uint256 _tokenId)external payable{
        require(msg.value==nftprice,"This NFT need 0.1 ether to pay");
        tokens[_tokenId]=msg.sender;
    }

    /**
     * @dev getprice of the nft
     */
    function getPrice() external view returns(uint256){
        return nftprice;
    }

    /**
     * @dev available() checks whether the given tokenId has already been sold or not
     */
    function available(uint256 _tokenId) external view returns(bool){
        if(tokens[_tokenId]==address(0)){
            return true;
        }
        return false;
    }
    
}