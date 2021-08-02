pragma solidity 0.4.24;

import "@aragon/templates-shared/contracts/TokenCache.sol";
import "@aragon/templates-shared/contracts/BaseTemplate.sol";


contract MembershipTemplate is BaseTemplate, TokenCache {
    string constant private ERROR_MISSING_MEMBERS = "MEMBERSHIP_MISSING_MEMBERS";
    string constant private ERROR_BAD_VOTE_SETTINGS = "MEMBERSHIP_BAD_VOTE_SETTINGS";
    string constant private ERROR_BAD_PAYROLL_SETTINGS = "MEMBERSHIP_BAD_PAYROLL_SETTINGS";

    bool constant private TOKEN_TRANSFERABLE = false;
    uint8 constant private TOKEN_DECIMALS = uint8(0);
    uint256 constant private TOKEN_MAX_PER_ACCOUNT = uint256(1);
    uint64 constant private DEFAULT_FINANCE_PERIOD = uint64(30 days);

    constructor(DAOFactory _daoFactory, ENS _ens, MiniMeTokenFactory _miniMeFactory, IFIFSResolvingRegistrar _aragonID)
        BaseTemplate(_daoFactory, _ens, _miniMeFactory, _aragonID)
        public
    {
        _ensureAragonIdIsValid(_aragonID);
        _ensureMiniMeFactoryIsValid(_miniMeFactory);
    }

    /**
    * @dev Create a new MiniMe token and deploy a Membership DAO. This function does not allow Payroll
    *      to be setup due to gas limits.
    * @param _tokenName String with the name for the token used by share holders in the organization
    * @param _tokenSymbol String with the symbol for the token used by share holders in the organization
    * @param _id String with the name for org, will assign `[id].aragonid.eth`
    * @param _members Array of member addresses (1 token will be minted for each member)
    * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
    */
    function newTokenAndInstance(
        string _tokenName,
        string _tokenSymbol,
        string _id,
        address[] _members,
        uint64[3] _votingSettings,
        address admin
    )
        external
    {
        newToken(_tokenName, _tokenSymbol);
        newInstance(_id, _members, _votingSettings, admin);
    }

    /**
    * @dev Create a new MiniMe token and cache it for the user
    * @param _name String with the name for the token used by share holders in the organization
    * @param _symbol String with the symbol for the token used by share holders in the organization
    */
    function newToken(string memory _name, string memory _symbol) public returns (MiniMeToken) {
        MiniMeToken token = _createToken(_name, _symbol, TOKEN_DECIMALS);
        _cacheToken(token, msg.sender);
        return token;
    }

    /**
    * @dev Deploy a Membership DAO using a previously cached MiniMe token
    * @param _id String with the name for org, will assign `[id].aragonid.eth`
    * @param _members Array of member addresses (1 token will be minted for each member)
    * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
    */
    function newInstance(
        string memory _id,
        address[] memory _members,
        uint64[3] memory _votingSettings,
        address admin
    )
        public
	{
        _validateId(_id);
        _ensureMembershipSettings(_members, _votingSettings);

        (Kernel dao, ACL acl) = _createDAO();
        Voting voting = _setupApps(dao, acl, _members, _votingSettings, admin);
        _transferRootPermissionsFromTemplateAndFinalizeDAO(dao, voting);
        _registerID(_id, dao);
    }

    function _setupApps(
        Kernel _dao,
        ACL _acl,
        address[] memory _members,
        uint64[3] memory _votingSettings,
        address admin
    )
        internal
        returns (Voting)
    {
        MiniMeToken token = _popTokenCache(msg.sender);
        TokenManager tokenManager = _installTokenManagerApp(_dao, token, TOKEN_TRANSFERABLE, TOKEN_MAX_PER_ACCOUNT);
        Voting voting = _installVotingApp(_dao, token, _votingSettings);
        _mintTokens(_acl, tokenManager, _members, 1);
        _setupPermissions(_acl, voting, tokenManager, admin);

        return (voting);
    }



    function _setupPermissions(
        ACL _acl,
        Voting _voting,
        TokenManager _tokenManager,
        address admin
    )
        internal
    {
        _createEvmScriptsRegistryPermissions(_acl, _voting, _voting);
        _createVotingPermissions(_acl, _voting, _voting, _tokenManager, _voting, admin);
        _createTokenManagerPermissions(_acl, _tokenManager, admin, admin);
    }


    function _ensureMembershipSettings(address[] memory _members, uint64[3] memory _votingSettings) private pure {
        require(_members.length > 0, ERROR_MISSING_MEMBERS);
        require(_votingSettings.length == 3, ERROR_BAD_VOTE_SETTINGS);
    }
}
