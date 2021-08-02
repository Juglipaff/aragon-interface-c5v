pragma solidity 0.4.24;

import "@aragon/os/contracts/acl/ACL.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/apps-voting/contracts/Voting.sol";
import "@aragon/apps-shared-minime/contracts/MiniMeToken.sol";

contract Manager {
    
     /**
     * @dev External Contracts:
     * {tokenManager} - Token Manager app.
     * {voting} - Voting app.
     * {acl} - ACL contract.
     */
    MiniMeToken public token;
    TokenManager public tokenManager;
    Voting public voting;
    ACL public acl;
    
    bool public initialized;
    address public manager;
    
    mapping(address => uint256) private adminPointer;
    address[] public adminList;
    
    constructor(address _manager) public {
        manager = _manager;
    }
    
    
    modifier onlyManager() {
        require(manager == msg.sender, "Caller is not the manager");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == manager || isAdmin(msg.sender), "Caller is not an admin");
        _;
    }
    
    modifier isInitialized() {
        require(initialized == true, "The contract is not yet initialized");
        _;
    }
    modifier isTokenHolder(address _address) {
        require (token.balanceOf(_address) > 0, 'The address is not a token holder');
        _;
    }
 
    
     /**
     * @dev initialize():
     * Initializes this contract with external contract addresses and sets {initialized} to true.
     */
    function initialize(TokenManager _tokenManager, Voting _voting, ACL _acl) onlyManager external {
       initialized = true;
       tokenManager = _tokenManager;
       token = tokenManager.token();
       voting = _voting;
       acl = _acl;
    }
    
    /**
     * @dev transferManager():
     * Transfer manager rights to another address.
     */
    function transferManager(address _address) onlyManager external {
        manager = _address;
    }
    
    /**
     * @dev burn():
     * Burns the membership token and revokes all rights from the {_address}.
     */
    function burn(address _address) onlyAdmin isInitialized external {
        tokenManager.burn(_address, 1);
        removeAdmin(_address);
        acl.revokePermission(_address, voting, voting.VOTE());
    }
    
    /**
     * @dev mint():
     * Mints the membership token and grants the right to vote.
     */
    function mint(address _address) onlyAdmin isInitialized external {
       tokenManager.mint(_address, 1);
       acl.grantPermission(_address, voting, voting.VOTE());
    }
    
     /**
     * @dev addExpert():
     * Assigns "expert" role to the {_address}.
     */
    function addExpert(address _address) onlyAdmin isInitialized isTokenHolder(_address) external { 
        removeAdmin(_address);
        acl.revokePermission(_address, voting, voting.VOTE());
    }
    
     /**
     * @dev addMember():
     * Assigns "member" role to the {_address}.
     */
    function addMember(address _address) onlyAdmin isInitialized isTokenHolder(_address) external {
        removeAdmin(_address);
        acl.grantPermission(_address, voting, voting.VOTE());
    }
    
    /**
     * @dev addAdmin():
     * Assigns "admin" role to the {_address}, stores the address in {adminList} and the pointer to it in the {adminPointer}.
     */
    function addAdmin(address _address) onlyAdmin isInitialized isTokenHolder(_address) external { 
        acl.grantPermission(_address, voting, voting.VOTE());
        if (!isAdmin(_address)) {
            adminPointer[_address] = adminList.push(_address) - 1;
        }
    }
    
    /**
     * @dev removeAdmin():
     * Removes {_address} from the {adminList} array.
     */
    function removeAdmin(address _address) internal {
        require (_address != manager, 'Cant remove the manager');
        if (isAdmin(_address)) {
            uint256 rowToDelete = adminPointer[_address];
            address keyToMove = adminList[adminList.length - 1];
            adminList[rowToDelete] = keyToMove;
            adminPointer[keyToMove] = rowToDelete;
            adminList.length--;
        }
    }
     
    /**
     * @dev getAdmins():
     * Returns {adminList}. 
     * Todo: UNSCALABLE! Remove the function and move array fetching to the backend.
     */ 
    function getAdmins() public view returns(address[] memory) {
        return adminList;
    }
    
    function getAdminsCount() public constant returns (uint256 entityCount) {
        return adminList.length;
    }
    
    function isAdmin(address _address) public constant returns (bool isIndeed) { 
        if (adminList.length == 0) return false;
        if(adminPointer[_address] > adminList.length - 1)  return false;
        return (adminList[adminPointer[_address]] == _address);
    }
    
    /**
     * @dev assignName()/assignPosition():
     * Assigns name/position string to the address.
     */ 
    function assignName(address _address, string _name) onlyAdmin isInitialized isTokenHolder(_address) external { 
        tokenManager.assignName(_address, _name);
    }
    
    function assignPosition(address _address, string _position) onlyAdmin isInitialized isTokenHolder(_address) external { 
        tokenManager.assignPosition(_address, _position);
    }
    
    /**
     * @dev hasVotePermission():
     * Returns {hasPermission} for {_address}.
     */ 
    function hasVotePermission(address _address) isInitialized public view returns (bool hasPermission) { 
       return acl.hasPermission(_address, voting, voting.VOTE()); 
    }
    
}

