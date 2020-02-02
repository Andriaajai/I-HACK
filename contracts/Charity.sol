pragma solidity ^0.4.18;

contract Charity {

    address public creator;
    mapping (address => uint) public donations;
    bytes32[] public votingOptions;
    address[] public votingOptionAddresses;
    uint[] public votingOptionVotes;
    uint public votingOptionsCount;
    uint public startTime;
    uint public endTime;

    event optionAdded(bytes32 option, address optionAddress);
    event donated(address donor, uint donationAmount);

    function Charity() public {
        creator = msg.sender;
        startTime = 2**256 - 1;
        endTime = 2**256 - 1;
    }
    function addVoteOption(bytes32 option, address optionAddress) public {
        if (msg.sender == creator && startTime == (2**256 - 1)) {

            if (votingOptions.length <= votingOptionsCount) {
                votingOptions.push("");
                votingOptionAddresses.push(0);
                votingOptionVotes.push(0);
            }
            votingOptions[votingOptionsCount] = option;
            votingOptionAddresses[votingOptionsCount] = optionAddress;
            votingOptionVotes[votingOptionsCount] = 0;
            votingOptionsCount++;
            emit optionAdded(option, optionAddress);
        }
    }

    function startVoting(uint duration) public {
        if (msg.sender == creator && startTime == 2**256 - 1 && now < endTime) {
            startTime = now;
            endTime = now + duration;
        }
    }

    function returnDonation() public {
        if (donations[msg.sender] > 0) {
            donations[msg.sender] = 0;
            msg.sender.transfer(donations[msg.sender]);
        }
    }
    function vote(uint option) public {
        if (isVotingActive() && option < votingOptionsCount) {
            uint temp = donations[msg.sender];
            donations[msg.sender] = 0;
            votingOptionVotes[option] += temp;
        }
    }

    function isVotingActive() public returns (bool) {
        return (now >= startTime && now <= endTime);
    }

    function disperse() public returns (bool){
        if (now >= endTime) {
            uint maxVotes = 0;
            uint maxIndex = 2**256 - 1;
            for (uint i = 0; i < votingOptionsCount; i++) {
                if (votingOptionVotes[i] > maxVotes) {
                    maxIndex = i;
                    maxVotes = votingOptionVotes[i];
                    votingOptionVotes[i] = 0;
                }
            }
            votingOptionsCount = 0;
            startTime = 2**256 - 1;
            endTime = 2**256 - 1;
            if (maxIndex == 2**256 - 1) {
                return false; //no one voted
            } else {
                votingOptionAddresses[maxIndex].transfer(address(this).balance);
            }
            return true;
        }
        return false;
    }
    function donate() public payable {
        donations[msg.sender] += msg.value;
        emit donated(msg.sender, msg.value);
    }

    function getBalance() public constant returns (uint) {
        return address(this).balance;
    }
    function getVotingOption (uint index) public constant returns (bytes32, address, uint) {
        if (index < votingOptionsCount) {
            return (votingOptions[index], votingOptionAddresses[index], votingOptionVotes[index]);
        } else {
            return ("null", 0, 0);
        }
    }

    function getAccountBalance(address addr) public view returns(uint) {
		  return addr.balance;
	  }
}
