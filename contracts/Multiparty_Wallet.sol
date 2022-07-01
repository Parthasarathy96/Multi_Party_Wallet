//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract multiPartyWallet is Ownable{
    address private Admin;

    // Stores the proposal ID used in mapping(proposals)
    uint32 public proposalID;

    //Status of saved proposals
    enum proposalStatus{PROPOSED, EXECUTED }

    //Stores owner's addresses
    address[] public _Owners;
    mapping(address => bool) public Owners;

    //Percentage of approval needed for execution
    uint8 private Percentage;

    //proposals storing format
    struct proposal{
        address ownerAddress;
        string proposal;
        address targetAddress;
        uint Amount;
        uint32 ApprovalCount;
        proposalStatus status;
    }
    
    //Stores proposals
    mapping(uint32 => proposal) public proposals;

    //Stores the approvals
    mapping(uint32 => mapping(address => bool)) public Approval;

    //Events
    event ownerAdded(address admin , address Owner);
    event ownerRemoved(address admin , address Owner);
    event Received(address sender, uint _amount);
    event Proposed(address owner , uint _proposalID);
    event proposalExecuted(address _owner, address targetAddress, uint _amount);


    constructor(){
        Admin = msg.sender;
        Percentage = 60;
    }
//ADD OWNER
    function addOwner(address _ownerAddress) public onlyOwner{
        require(Owners[msg.sender] != true, "Owner already exist");
        Owners[_ownerAddress] = true;
        _Owners.push(_ownerAddress);
        emit ownerAdded(msg.sender, _ownerAddress);
    }
//REMOVE OWNER
    function removeOwner(address _ownerAddress) public onlyOwner{
        require(Owners[_ownerAddress] == true, "Owner does not exist");
        Owners[_ownerAddress] = false;
        _Owners.pop();
        emit ownerRemoved(msg.sender, _ownerAddress);
    }

//ADD PROPOSALS
    function addProposal(string memory _proposal,address _targetAddress, uint _amount ) public checkOwner returns(bool){
        require(address(this).balance > _amount, "Not enough ether in contract");
        proposals[proposalID] = proposal(msg.sender, _proposal, _targetAddress, _amount, 0, proposalStatus.PROPOSED);
        emit Proposed(msg.sender, proposalID );
        proposalID += 1;
        return true;
    }
//APPROVE THE PROPOSOLS
    function approve(uint32 _proposalID) public checkOwner returns(bool){
        require(Approval[_proposalID][msg.sender] != true, "You have already approved the proposal");
        require(proposals[_proposalID].ownerAddress != msg.sender, "Proposer of this proposal cannot approve");
        Approval[_proposalID][msg.sender] == true;
        proposals[_proposalID].ApprovalCount += 1; 
        return true;
    }

//EXECUTE PROPOSALS
    function executeProposal(uint32 _proposalID) public payable checkOwner returns(bool) {
        require(proposals[_proposalID].ownerAddress == msg.sender, "you are not the proposer of this proposal");
        require(proposals[_proposalID].status == proposalStatus.EXECUTED, " Proposal is already executed");
        uint _amount = proposals[_proposalID].Amount;
        address _targetAddress = proposals[_proposalID].targetAddress;
        uint _percentage = (proposals[_proposalID].ApprovalCount*100/_Owners.length);
        if(_percentage > Percentage && address(this).balance > (_amount)){
            payable(address(_targetAddress)).transfer(_amount);
            emit proposalExecuted(msg.sender, _targetAddress, _amount);
            proposals[_proposalID].status = proposalStatus.EXECUTED;
            return true;
        }else{
            return false;
        }
    }
//VIEW THE STATUS OF PROPOSALS
    function Statusproposal(uint32 _proposalID) public view checkOwner returns (proposalStatus, uint32 ){
        return (proposals[_proposalID].status, proposals[_proposalID].ApprovalCount);
    }

//UPDATES THE PERCENTAGE OF APPROVAL NEEDED FOR PROPOSAL EXECUTION
    function updateProposalPercentage(uint8 _percentage) public onlyOwner returns(bool){
        require(_percentage < 100 && _percentage > 60, "Invalid Percentage");
        Percentage = _percentage;
        return true;
    }

     //OWNERS COUNT 
    function getOwner() public view returns(address[] memory){
        return _Owners;
    }
    
//MODIFIER TO CHECK IF THE USER IS OWNER
    modifier checkOwner{
        require(Owners[msg.sender] == true, " Caller is not a owner");
        _;
    }

      
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

     fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

}