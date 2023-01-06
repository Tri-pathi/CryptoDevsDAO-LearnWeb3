// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * Interface for the FakeNFTMarketplace
 * 
 */
interface IFakeNFTMarketplace {

    function getPrice() external view returns(uint256);

    function available(uint256 _tokenId) external view returns(bool);

    function purchase(uint256 _tokenId) external payable;
    
}

/**
 * Interface for CryptoDevsNFT contract that we have used to give permission to mint NFT who are in white
 * listed or who wanna buy
 * main goal is that we will make DAO with the help of NFT holders
 * We want to allow your NFT holders to create and vote
 *  on proposals to use that ETH for purchasing other
 *  NFTs from an NFT marketplace in our case this is or FakeNFTMarketplace
 * 
 * 
 */
interface ICryptoDevsNFT {

    function balanceOf(address owner) external view returns(uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);


    
}
/**
 * the Function that we need in our DAO contract
 * store created proposals in contract state
 * Allows holders of the CryptoDevs NFT to create new proposal
 * Allow holders of the CryptoDevs NFT to vote on proposals,
 * You want to allow your NFT holders to create and vote on proposals
 *  to use that ETH for purchasing other NFTs from an NFT marketplace
 * Allow holders of the CryptoDevs NFT to execute a proposal after it's 
 * deadline has been exceeded, triggering an NFT purchase in case it passed
 */
contract CryptoDevsDAO is Ownable{
    // Create a struct named Proposal containing all relevant information
    struct Proposal{
        //the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
    uint256 nftTokenId;
    uint256 deadline;
    uint256 yayVotes;
    uint256 nayVotes;
    bool executed;
    mapping (uint256 => bool) voters;

    }

    //enum
    enum Vote {
    YAY, // YAY = 0
    NAY // NAY = 1
}
    // Create a mapping of ID to Proposal
mapping(uint256 => Proposal) public proposals;

uint256 public numProposals;

//Contract Address to use the Interfaces

ICryptoDevsNFT private immutable cryptoDevsNFT;
IFakeNFTMarketplace private immutable nftMarketplace;
// The payable allows this constructor to accept an ETH deposit when it is being deployed

constructor(address _cryptoDevsNFT,address _nftMarketplace) payable {
    cryptoDevsNFT=ICryptoDevsNFT(_cryptoDevsNFT);
    nftMarketplace=IFakeNFTMarketplace(_nftMarketplace);

}
modifier nftHolderOnly {
    require(cryptoDevsNFT.balanceOf(msg.sender)>0,"NOT_A_DAO_MEMBER");
    _;
}
function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
    require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
    Proposal storage proposal = proposals[numProposals];
    proposal.nftTokenId = _nftTokenId;
    // Set the proposal's voting deadline to be (current time + 5 minutes)
    proposal.deadline = block.timestamp + 5 minutes;

    numProposals++;

    return numProposals - 1;
    
}

// Create a modifier which only allows a function to be
// called if the given proposal's deadline has not been exceeded yet
modifier activeProposalOnly(uint256 proposalIndex) {
    require(
        proposals[proposalIndex].deadline > block.timestamp,
        "DEADLINE_EXCEEDED"
    );
    _;
}
function voteOnProposal(uint256 proposalIndex, Vote vote)
    external
    nftHolderOnly
    activeProposalOnly(proposalIndex)
{
    Proposal storage proposal = proposals[proposalIndex];

    uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
    uint256 numVotes = 0;

    // Calculate how many NFTs are owned by the voter
    // that haven't already been used for voting on this proposal
    for (uint256 i = 0; i < voterNFTBalance; i++) {
        uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
        if (proposal.voters[tokenId] == false) {
            numVotes++;
            proposal.voters[tokenId] = true;
        }
    }
    require(numVotes > 0, "ALREADY_VOTED");

    if (vote == Vote.YAY) {
        proposal.yayVotes += numVotes;
    } else {
        proposal.nayVotes += numVotes;
    }
}
// Create a modifier which only allows a function to be
// called if the given proposals' deadline HAS been exceeded
// and if the proposal has not yet been executed
modifier inactiveProposalOnly(uint256 proposalIndex) {
    require(
        proposals[proposalIndex].deadline <= block.timestamp,
        "DEADLINE_NOT_EXCEEDED"
    );
    require(
        proposals[proposalIndex].executed == false,
        "PROPOSAL_ALREADY_EXECUTED"
    );
    _;
}
function executeProposal(uint256 proposalIndex)
    external
    nftHolderOnly
    inactiveProposalOnly(proposalIndex)
{
    Proposal storage proposal = proposals[proposalIndex];

    // If the proposal has more YAY votes than NAY votes
    // purchase the NFT from the FakeNFTMarketplace
    if (proposal.yayVotes > proposal.nayVotes) {
        uint256 nftPrice = nftMarketplace.getPrice();
        require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
        nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
    }
    proposal.executed = true;
}
/// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
function withdrawEther() external onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "Nothing to withdraw; contract balance empty");
    payable(owner()).transfer(amount);
}
receive() external payable {}

fallback() external payable {}

}