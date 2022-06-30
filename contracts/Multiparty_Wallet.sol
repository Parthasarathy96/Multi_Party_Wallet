//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract multiPartyWallet is Ownable{
    address private Admin;
    uint32 public proposalID;
    enum proposalStatus{PROPOSED, EXECUTED }

    address[] public _Owners;
    mapping(address => bool) private Owners;

    uint8 private Percentage;

    struct proposal{
        address ownerAddress;
        string proposal;
        address targetAddress;
        uint Amount;
        uint32 ApprovalCount;
        proposalStatus status;
    }
    
    mapping(uint32 => proposal) public proposals;
    mapping(uint32 => mapping(address => bool)) public Approval;


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
        Owners[_ownerAddress] = true;
        _Owners.push(_ownerAddress);
        emit ownerAdded(msg.sender, _ownerAddress);
    }
//REMOVE OWNER
    function removeOwner(address _ownerAddress) public onlyOwner{
        Owners[_ownerAddress] = false;
        _Owners.pop();
        emit ownerAdded(msg.sender, _ownerAddress);
    }


    function addProposal(string memory _proposal,address _targetAddress, uint _amount ) public checkOwner returns(bool){
        require(address(this).balance > _amount, "Not enough ether in contract");
        proposals[proposalID] = proposal(msg.sender, _proposal, _targetAddress, _amount, 0, proposalStatus.PROPOSED);
        emit Proposed(msg.sender, proposalID );
        proposalID += 1;
        return true;
    }

    function approve(uint32 _proposalID) public checkOwner returns(bool){
        require(Approval[_proposalID][msg.sender] == true, "You have already approved the proposal");
        require(proposals[_proposalID].ownerAddress != msg.sender, "Proposer of this proposal cannot approve");
        Approval[_proposalID][msg.sender] == true;
        proposals[_proposalID].ApprovalCount += 1; 
        return true;
    }

    function executeProposal(uint32 _proposalID) public payable checkOwner returns(bool) {
        require(proposals[_proposalID].ownerAddress == msg.sender, "you are not the proposer of this proposal");
        require(proposals[_proposalID].status == proposalStatus.EXECUTED, " Proposal is already executed");
        uint _amount = proposals[_proposalID].Amount;
        address _targetAddress = proposals[_proposalID].targetAddress;
        uint _percentage = ((proposals[_proposalID].ApprovalCount/_Owners.length)*100);
        if(_percentage > Percentage && address(this).balance > (_amount)){
            payable(address(_targetAddress)).transfer(_amount);
            emit proposalExecuted(msg.sender, _targetAddress, _amount);
            proposals[_proposalID].status = proposalStatus.EXECUTED;
            return true;
        }else{
            return false;
        }
    }

    function Statusproposal(uint32 _proposalID) public view checkOwner returns (proposalStatus, uint32 ){
        return (proposals[_proposalID].status, proposals[_proposalID].ApprovalCount);
    }

    function updateProposalPercentage(uint8 _percentage) public onlyOwner returns(bool){
        require(_percentage < 100 && _percentage > 60, "Invalid Percentage");
        Percentage = _percentage;
        return true;
    }

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
