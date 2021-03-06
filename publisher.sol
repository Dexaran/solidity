pragma solidity ^0.4.11;

import "announcementTypes.sol";
import "module.sol";
import "moduleHandler.sol";
import "safeMath.sol";

contract publisher is announcementTypes, module, safeMath {
    /*
        module callbacks
    */
    function connectModule() external returns (bool) {
        require( super._connectModule() );
        return true;
    }
    function disconnectModule() external returns (bool) {
        require( super._disconnectModule() );
        return true;
    }
    function replaceModule(address addr) external returns (bool) {
        require( super._replaceModule(addr) );
        return true;
    }
    function disableModule(bool forever) external returns (bool) {
        require( super._disableModule(forever) );
        return true;
    }
    function isActive() public constant returns (bool) {
        return super._isActive();
    }
    function replaceModuleHandler(address newHandler) external returns (bool) {
        require( super._replaceModuleHandler(newHandler) );
        return true;
    }
    function transferEvent(address from, address to, uint256 value) external returns (bool) {
        /*
            Transaction completed. This function is available only for moduleHandler
            If a transaction is carried out from or to an address which participated in the objection of an announcement, its objection purport is automatically set
        */
        require( super._isModuleHandler(msg.sender) );
        uint256 announcementID;
		uint256 a;
        for ( a=0 ; a<opponents[from].announcements.length ; a++ ) {
            announcementID = opponents[msg.sender].announcements[a];
            if ( announcements[announcementID].end < block.number && announcements[announcementID].open ) {
                announcements[announcementID].oppositionWeight = safeSub(announcements[a].oppositionWeight, value);
                opponents[from].weight = safeSub(opponents[from].weight, value);
            }
        }
        for ( a=0 ; a<opponents[to].announcements.length ; a++ ) {
            announcementID = opponents[msg.sender].announcements[a];
            if ( announcements[announcementID].end < block.number && announcements[announcementID].open ) {
                announcements[announcementID].oppositionWeight = safeAdd(announcements[a].oppositionWeight, value);
                opponents[to].weight = safeAdd(opponents[to].weight, value);
            }
        }
        return true;
    }
    modifier isReady { require( super._isActive() ); _; }
    
    /*
        Pool
    */
    
    mapping(address => bool) private admins;
    
    uint256 private minAnnouncementDelay = 40320;
    uint256 private minAnnouncementDelayOnICO = 17280;
    uint8 private oppositeRate = 33;
    address private owner = msg.sender;
    
    struct _announcements {
        announcementType Type;
        uint256 start;
        uint256 end;
        bool open;
        string announcement;
        string link;
        bool oppositable;
        uint256 oppositionWeight;
        bool result;
        
        string _str;
        uint256 _uint;
        address _addr;
    }
    _announcements[] private announcements;
    
    struct _opponents {
        uint256[] announcements;
        uint256 weight;
    }
    mapping (address => _opponents) opponents;
    
    function publisher(address _moduleHandler) {
        /*
            Installation function.  The installer will be registered in the admin list automatically        
            @_moduleHandler     address of moduleHandler
        */
        require( super._registerModuleHandler(_moduleHandler) );
        admins[msg.sender] = true;
    }
    
    function addAdmin(address addr) onlyOwner external {
        /*
            Add Admin 
            
            @addr       new admin address.
        */
        admins[addr] = true;
    }

    function delAdmin(address addr) onlyOwner external {
        /*
            Remove Admin             
            @addr       address of admin to remove.
        */
        delete admins[addr];
    }
    
    function Announcements(uint256 id) public constant returns (uint256 Type, uint256 Start, uint256 End, bool Closed, string Announcement, string Link, bool Opposited, string _str, uint256 _uint, address _addr) {
        /*
            Announcement data query
            
            @id             its identification
            @Type           subject of announcement
            @Start          height of announcement block
            @End            planned completion of announcement
            @Closed         Closed or not
            @Announcement   Announcement text
            @Link           link  perhaps to a Forum 
            @Opposited      Objected or not
            @_str           text box
            @_uint          number box
            @_addr          address box
        */
        Type = uint256(announcements[id].Type);
        Start = announcements[id].start;
        End = announcements[id].end;
        Closed = ! announcements[id].open;
        Announcement = announcements[id].announcement;
        Link = announcements[id].link;
        if ( checkOpposited(announcements[id].oppositionWeight, announcements[id].oppositable) ) {
            Opposited = true;
        }
        _str = announcements[id]._str;
        _uint = announcements[id]._uint;
        _addr = announcements[id]._addr;
    }
    
    function checkOpposited(uint256 weight, bool oppositable) internal returns (bool) {
        /*
            veto check
            
            @weight         purport of objections so far
            @oppositable    opposable at all
            @bool           Opposed or not
        */
        if ( ! oppositable ) { return false; }
        var (a, b) = moduleHandler(super._getModuleHandlerAddress()).totalSupply();
        require( b );
        return a * oppositeRate / 100 > weight;
    }
    
    function newAnnouncement(announcementType Type, string Announcement, string Link, bool Oppositable, string _str, uint256 _uint, address _addr) isReady onlyAdmin external {
        /*
            New announcement. Can be called  only by those in the admin list
            
            @Type           Topic of announcement
            @Start          height of announcement block
            @End            planned completion of announcement
            @Closed         Completed or not
            @Announcement   Announcement text
            @Link           link to a Forum 
            @Opposition     opposed or not
            @_str           text box
            @_uint          number box
            @_addr          address box
        */
        _announcements memory tmpAnnouncement;
        tmpAnnouncement.Type = Type;
        tmpAnnouncement.start = block.number;
        if ( checkICO() ) {
            tmpAnnouncement.end = block.number + minAnnouncementDelayOnICO;
        } else {
            tmpAnnouncement.end = block.number + minAnnouncementDelay;
        }
        tmpAnnouncement.open = true;
        tmpAnnouncement.announcement = Announcement;
        tmpAnnouncement.link = Link;
        tmpAnnouncement.oppositable = Oppositable;
        tmpAnnouncement.oppositionWeight = 0;
        tmpAnnouncement.result = false;
        tmpAnnouncement._str = _str;
        tmpAnnouncement._uint = _uint;
        tmpAnnouncement._addr = _addr;
        ENewAnnouncement(announcements.push(tmpAnnouncement), Type);
    }
    
    function closeAnnouncement(uint256 id) isReady onlyAdmin external {
        /*
            Close announcement. It can be closed only by those in the admin list. Windup is allowed only after the announcement is completed.
            
            @id     Announcement identification
        */
        require( announcements[id].open && announcements[id].end < block.number );
        if ( ! checkOpposited(announcements[id].oppositionWeight, announcements[id].oppositable) ) {
            announcements[id].result = true;
            if ( announcements[id].Type == announcementType.newModule ) {
                require( moduleHandler(super._getModuleHandlerAddress()).newModule(announcements[id]._str, announcements[id]._addr, true, true) );
            } else if ( announcements[id].Type == announcementType.dropModule ) {
                require( moduleHandler(super._getModuleHandlerAddress()).dropModule(announcements[id]._str) );
            } else if ( announcements[id].Type == announcementType.replaceModule ) {
                require( moduleHandler(super._getModuleHandlerAddress()).replaceModule(announcements[id]._str, announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.replaceModuleHandler) {
                require( moduleHandler(super._getModuleHandlerAddress()).replaceModuleHandler(announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.transactionFeeRate || 
                        announcements[id].Type == announcementType.transactionFeeMin || 
                        announcements[id].Type == announcementType.transactionFeeMax || 
                        announcements[id].Type == announcementType.transactionFeeBurn ) {
                require( moduleHandler(super._getModuleHandlerAddress()).configureToken(announcements[id].Type, announcements[id]._uint) );
            } else if ( announcements[id].Type == announcementType.providerPublicFunds || 
                        announcements[id].Type == announcementType.providerPrivateFunds || 
                        announcements[id].Type == announcementType.providerPrivateClientLimit || 
                        announcements[id].Type == announcementType.providerPublicMinRate || 
                        announcements[id].Type == announcementType.providerPublicMaxRate || 
                        announcements[id].Type == announcementType.providerPrivateMinRate || 
                        announcements[id].Type == announcementType.providerPrivateMaxRate || 
                        announcements[id].Type == announcementType.providerGasProtect || 
                        announcements[id].Type == announcementType.providerInterestMinFunds || 
                        announcements[id].Type == announcementType.providerRentRate ) {
                require( moduleHandler(super._getModuleHandlerAddress()).configureProvider(announcements[id].Type, announcements[id]._uint) );
            } else if ( announcements[id].Type == announcementType.schellingRoundBlockDelay || 
                        announcements[id].Type == announcementType.schellingCheckRounds || 
                        announcements[id].Type == announcementType.schellingCheckAboves || 
                        announcements[id].Type == announcementType.schellingRate ) {
                require( moduleHandler(super._getModuleHandlerAddress()).configureSchelling(announcements[id].Type, announcements[id]._uint) );
            } else if ( announcements[id].Type == announcementType.publisherMinAnnouncementDelay) {
                minAnnouncementDelay = announcements[id]._uint;
            } else if ( announcements[id].Type == announcementType.publisherOppositeRate) {
                oppositeRate = uint8(announcements[id]._uint);
            }
        }
        announcements[id].end = block.number;
        announcements[id].open = false;
    }
    
    function oppositeAnnouncement(uint256 id) isReady external {
        /*
            Opposition of announcement
            If announcement is opposable, anyone owning a token can oppose it
            Opposition is automatically with the total amount of tokens
            If the quantity of his tokens changes, the purport of his opposition changes automatically
            The prime time is the windup  of the announcement, because this is the moment when the number of tokens in opposition are counted.
            One address is entitled to be in oppositon only once. An opposition cannot be withdrawn. 
            Running announcements can be opposed only.

            @id     Announcement identification
        */
        require( announcements[id].open );
        require( announcements[id].oppositable );
        for ( uint256 a=0 ; a<opponents[msg.sender].announcements.length ; a++ ) {
               require( opponents[msg.sender].announcements[a] != id );
        }
        var (bal, s) = moduleHandler(super._getModuleHandlerAddress()).balanceOf(msg.sender);
        require( s );
        require( bal > 0);
        opponents[msg.sender].weight = bal;
        announcements[id].oppositionWeight += bal;
        EOppositeAnnouncement(id, msg.sender, bal);
    }
    
    function invalidateAnnouncement(uint256 id) isReady onlyAdmin external {
        /*
            Withdraw announcement. Only those in the admin list can withdraw it.            
            @id     Announcement identification
        */
        require( announcements[id].open );
        announcements[id].end = block.number;
        announcements[id].open = false;
        EInvalidateAnnouncement(id);
    }
    
    modifier onlyAdmin() {
        /*
            Only those in the admin list can call it.
        */
        require( admins[msg.sender] ); _;
    }
    
    modifier onlyOwner() {
        /*
            Only the owner  is allowed to call it.      
        */
        require( owner == msg.sender ); _;
    }
    
    function checkICO() internal returns (bool) {
        /*
            Inner function to check the ICO status.
            @bool       Is the ICO in proccess or not?
        */
        var (a, b) = moduleHandler(super._getModuleHandlerAddress()).isICO();
        require( b );
        return a;
    }
    
    event ENewAnnouncement(uint256 id, announcementType typ);
    event EOppositeAnnouncement(uint256 id, address addr, uint256 value);
    event EInvalidateAnnouncement(uint256 id);
    event ECloseAnnouncement(uint256 id);
    
}