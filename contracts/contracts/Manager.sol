pragma solidity 0.4.24;

import "@aragon/os/contracts/acl/ACL.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";

contract Manager{
    bool public initialized;
    TokenManager public tokenManager;
    address public manager;
    
    mapping(address => uint256) public admins;
    address[] public adminsArr;
    
    constructor(address _manager) public{
        manager = _manager;
    }
    
    modifier onlyManager() {
        require(manager == msg.sender, "Caller is not the manager");
        _;
    }
    
    modifier onlyAdmin() {
        uint256 index = admins[msg.sender];
        require(msg.sender == manager || (index >= 0 && index < adminsArr.length && adminsArr[index] == msg.sender), "Caller is not an admin");
        _;
    }
    
    modifier isInitialized() {
        require(initialized == true, "The contract is not yet initialized");
        _;
    }
    
    function initialize(TokenManager _tokenManager) onlyManager external{
       initialized = true;
       tokenManager = _tokenManager;
    }
    
    function transferManager(address newManager) onlyManager external{
        manager = newManager;
    }
    
    function burn(address _holder, uint256 _amount) onlyAdmin isInitialized external{
        tokenManager.burn(_holder, _amount);
        removeAdmin(_holder);
    }
    
    function mint(address _receiver, uint256 _amount) onlyAdmin isInitialized external{
        tokenManager.mint(_receiver, _amount);
    }
    
    function addAdmin(address admin) onlyAdmin external{
                admins[admin] = adminsArr.length;
                adminsArr.push(admin);
    }
    
    function removeAdmin(address admin) onlyAdmin public{
        require (admin != manager, 'Cant remove the manager');
           if (adminsArr.length > 1) {
                    adminsArr[admins[admin]] = adminsArr[adminsArr.length - 1];
                    admins[admin] = 0;
                }
                adminsArr.length--;
    }
    
     
    function getAdmins() public view returns(address[] memory){
        return adminsArr;
    }
    
    function assignName(address _receiver, string _name) onlyAdmin external {
        tokenManager.assignName(_receiver, _name);
    }
    
    function assignPosition(address _receiver, string _position) onlyAdmin external {
        tokenManager.assignPosition(_receiver, _position);
    }
}