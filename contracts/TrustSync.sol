// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TrustSync !
 * @dev A decentralized trust and reputation system for collaborative agreements
 */
contract Project {
    
    struct Agreement {
        address party1;
        address party2;
        string description;
        uint256 value;
        bool isCompleted;
        bool isDisputed;
        uint256 createdAt;
        uint256 completedAt;
    }
    
    struct UserProfile {
        uint256 reputationScore;
        uint256 completedAgreements;
        uint256 disputedAgreements;
        bool isRegistered;
    }
    
    mapping(uint256 => Agreement) public agreements;
    mapping(address => UserProfile) public userProfiles;
    mapping(address => uint256[]) public userAgreements;
    
    uint256 public agreementCounter;
    uint256 public constant REPUTATION_REWARD = 10;
    uint256 public constant REPUTATION_PENALTY = 5;
    
    event AgreementCreated(uint256 indexed agreementId, address indexed party1, address indexed party2, uint256 value);
    event AgreementCompleted(uint256 indexed agreementId, address indexed completedBy);
    event AgreementDisputed(uint256 indexed agreementId, address indexed disputedBy);
    event UserRegistered(address indexed user);
    
    modifier onlyPartyInAgreement(uint256 _agreementId) {
        require(
            msg.sender == agreements[_agreementId].party1 || 
            msg.sender == agreements[_agreementId].party2,
            "Not a party in this agreement"
        );
        _;
    }
    
    modifier agreementExists(uint256 _agreementId) {
        require(_agreementId < agreementCounter, "Agreement does not exist");
        _;
    }
    
    /**
     * @dev Register a new user in the TrustSync system
     */
    function registerUser() external {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            reputationScore: 100, // Start with base reputation
            completedAgreements: 0,
            disputedAgreements: 0,
            isRegistered: true
        });
        
        emit UserRegistered(msg.sender);
    }
    
    /**
     * @dev Create a new agreement between two parties
     * @param _party2 Address of the second party
     * @param _description Description of the agreement
     */
    function createAgreement(address _party2, string memory _description) external payable {
        require(userProfiles[msg.sender].isRegistered, "Party 1 not registered");
        require(userProfiles[_party2].isRegistered, "Party 2 not registered");
        require(_party2 != msg.sender, "Cannot create agreement with yourself");
        require(msg.value > 0, "Agreement must have value");
        
        uint256 agreementId = agreementCounter;
        
        agreements[agreementId] = Agreement({
            party1: msg.sender,
            party2: _party2,
            description: _description,
            value: msg.value,
            isCompleted: false,
            isDisputed: false,
            createdAt: block.timestamp,
            completedAt: 0
        });
        
        userAgreements[msg.sender].push(agreementId);
        userAgreements[_party2].push(agreementId);
        
        agreementCounter++;
        
        emit AgreementCreated(agreementId, msg.sender, _party2, msg.value);
    }
    
    /**
     * @dev Complete an agreement and update reputation scores
     * @param _agreementId ID of the agreement to complete
     */
    function completeAgreement(uint256 _agreementId) 
        external 
        agreementExists(_agreementId)
        onlyPartyInAgreement(_agreementId) 
    {
        Agreement storage agreement = agreements[_agreementId];
        
        require(!agreement.isCompleted, "Agreement already completed");
        require(!agreement.isDisputed, "Agreement is disputed");
        
        agreement.isCompleted = true;
        agreement.completedAt = block.timestamp;
        
        // Update reputation scores for both parties
        userProfiles[agreement.party1].reputationScore += REPUTATION_REWARD;
        userProfiles[agreement.party1].completedAgreements++;
        
        userProfiles[agreement.party2].reputationScore += REPUTATION_REWARD;
        userProfiles[agreement.party2].completedAgreements++;
        
        // Transfer value to party2 (service provider/receiver)
        payable(agreement.party2).transfer(agreement.value);
        
        emit AgreementCompleted(_agreementId, msg.sender);
    }
    
    /**
     * @dev Dispute an agreement (reduces reputation for the disputing party)
     * @param _agreementId ID of the agreement to dispute
     */
    function disputeAgreement(uint256 _agreementId) 
        external 
        agreementExists(_agreementId)
        onlyPartyInAgreement(_agreementId) 
    {
        Agreement storage agreement = agreements[_agreementId];
        
        require(!agreement.isCompleted, "Cannot dispute completed agreement");
        require(!agreement.isDisputed, "Agreement already disputed");
        
        agreement.isDisputed = true;
        
        // Reduce reputation for disputing party
        if (userProfiles[msg.sender].reputationScore >= REPUTATION_PENALTY) {
            userProfiles[msg.sender].reputationScore -= REPUTATION_PENALTY;
        }
        
        userProfiles[msg.sender].disputedAgreements++;
        
        // Refund value to party1 in case of dispute
        payable(agreement.party1).transfer(agreement.value);
        
        emit AgreementDisputed(_agreementId, msg.sender);
    }
    
    /**
     * @dev Get user's agreement history
     * @param _user Address of the user
     * @return Array of agreement IDs
     */
    function getUserAgreements(address _user) external view returns (uint256[] memory) {
        return userAgreements[_user];
    }
    
    /**
     * @dev Get user's reputation score
     * @param _user Address of the user
     * @return Reputation score
     */
    function getUserReputation(address _user) external view returns (uint256) {
        return userProfiles[_user].reputationScore;
    }

}


