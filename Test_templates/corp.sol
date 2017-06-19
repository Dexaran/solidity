pragma solidity ^0.4.11;

contract thirdPartyPContractAbstract {
    function receiveCorionPremiumToken(address, uint256, bytes) external returns (bool, uint256) {}
    function approvedCorionPremiumToken(address, uint256, bytes) external returns (bool) {}
}

contract ptokenDB {}

contract safeMath {
    function safeAdd(uint256 a, uint256 b) internal returns(uint256) {
        /*
            Biztonsagos hozzadas. Tulcsordulas elleni vedelem.
            A vegeredmeny nem lehet kevesebb mint az @a, ha igen megall a kod.
            
            @a          Amihez hozzaadni kell
            @b          Amennyit hozzaadni kell.
            @uint256    Vegeredmeny.
        */
        if ( b > 0 ) {
            assert( a + b > a );
        }
        return a + b;
    }
        
    function safeSub(uint256 a, uint256 b) internal returns(uint256) {
        /*
            Biztonsagos kivonas. Tulcsordulas elleni vedelem.
            A vegeredmeny nem lehet tobb mint az @a, ha igen megall a kod.
            
            @a          Amibol kivonni kell.
            @b          Amennyit kivonni kell.
            @uint256    Vegeredmeny.
        */
        if ( b > 0 ) {
            assert( a - b < a );
        }
        return a - b;
    }
}

contract premium is safeMath {
    
    
    // TESTING EVENTS
    
    event TEST_dbIncrease(address indexed _addr, uint indexed _amount);
    event TEST_dbDecrease(address indexed _addr, uint indexed _amount);
    
    
    
    
    
    /*
    
    function connectModule() external returns (bool) {
        require( super._connectModule() );
        return true;
    }
    function disconnectModule() external returns (bool) {
        require( super._disconnectModule() );
        return true;
    }
    function replaceModule(address addr) external returns (bool) {
        require( db.replaceOwner(addr) );
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
    }*/
    modifier isReady {  _; }
    /**
    *
    * @title Corion Platform Premium Token
    * @author iFA @ Corion Platform
    *
    */
    
    string public name = "Corion Premium";
    string public symbol = "CORP";
    uint8 public decimals = 0;
    
    address private icoAddr;
    //tokenDB private db;
    bool    public  isICO;
    
    struct _allowance {
        uint256 amount;
        uint256 nonce;
    }
    
    mapping(address => mapping(address => _allowance)) private allowance_;
    mapping(address => bool) private genesis;
    
    function premium() {
        /*
            Setup function.
            If an ICOaddress is defined then the balance of the genesis addresses will be set as well.
            
            @_forReplace        This address will be replaced with the old one or not.
            @_moduleHandler     modulhandler’s address
            @_db                Address of database
            @_icoAddr           address of ico contract.
            @genesisAddr        Array of the genesis addresses.
            @genesisValue       Array of the balance of the genesis addresses
        */
        //require( super._registerModuleHandler(_moduleHandler) );
        //require( _db != 0x00 );
        //db = ptokenDB(_db);
        /*if ( ! _forReplace ) {
        //  I'm not testing replacement functional now.
            require( db.replaceOwner(this) );
            isICO = true;
            icoAddr = _icoAddr;
            assert( genesisAddr.length == genesisValue.length );
            for ( uint256 a=0 ; a<genesisAddr.length ; a++ ) {
                genesis[genesisAddr[a]] = true;
                require( db.increase(genesisAddr[a], genesisValue[a]) );
                Mint(genesisAddr[a], genesisValue[a]);
            }
        }*/
    }
    
    function closeIco() external returns (bool) {
        /*
            Finishing the ICO. Can be invited only by an ICO contract.
            
            @bool        If the function was successful.
        */
        require( isICO );
        isICO = false;
        return true;
    }
    
    /**
     * @notice `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf.
     * @param _spender The address of the account able to transfer the tokens
     * @param _amount The amount of tokens to be approved for transfer
     * @param _nonce The transaction count of the authorised address
     * @return True if the approval was successful
     */
    function approve(address _spender, uint256 _amount, uint256 _nonce) isReady external returns (bool) {
        /*
            Authorize another address to use an exact amount of the principal’s balance.   
            
            @_spender           Address of authorised party
            @_amount            Token quantity
            @_nonce             Transaction count
            
            @bool               Was the Function successful?
        */
        approve_(_spender, _amount, _nonce);
        return true;
    }
    
    /**
     * @notice `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf and notify the spender from your approve with your `_extraData` data.
     * @param _spender The address of the account able to transfer the tokens
     * @param _amount The amount of tokens to be approved for transfer
     * @param _nonce The transaction count of the authorised address
     * @param _extraData Data to give forward to the receiver
     * @return True if the approval was successful
     */
    function approveAndCall(address _spender, uint256 _amount, uint256 _nonce, bytes _extraData) isReady external returns (bool) {
        /*
            Authorize another address to use an exact amount of the principal’s balance.
            After the transaction the approvedCorionPremiumToken function of the address will be called with the given data.
            
            @_spender           Authorized address
            @_amount            Token quantity
            @_extraData         Extra data to be received by the receiver
            @_nonce             Transaction count
            
            @bool               Was the Function successful?
        */
        approve_(_spender, _amount, _nonce);
        require( thirdPartyPContractAbstract(_spender).approvedCorionPremiumToken(msg.sender, _amount, _extraData) );
        return true;
    }
    
    function approve_(address _spender, uint256 _amount, uint256 _nonce) isReady internal {
        /*
            Inner function to authorize another address to use an exact amount of the principal’s balance. 
            If the transaction count not match the authorise fails.
            
            @_spender           Address of authorised party
            @_amount            Token quantity
            @_nonce             Transaction count
        */
        require( msg.sender != _spender );
        //require( db.balanceOf(msg.sender) >= _amount );
        require( allowance_[msg.sender][_spender].nonce == _nonce );
        allowance_[msg.sender][_spender].amount = _amount;
        Approval(msg.sender, _spender, _amount);
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining, uint256 nonce) {
        /*
            Get the quantity of tokens given to be used
            
            @_owner        Authorising address
            @_spender      Authorised address
            
            @remaining     Tokens to be spent
            @nonce         Transaction count
        */
        remaining = allowance_[_owner][_spender].amount;
        nonce = allowance_[_owner][_spender].nonce;
    }
    
    /**
     * @notice Send `_amount` Corion tokens to `_to` from `msg.sender`
     * @param _to The address of the recipient
     * @param _amount The amount of tokens to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _amount) isReady external returns (bool) {
        /*
            Launch a transaction where the token is sent from the sender’s address to the receiver’s address.
            Transaction fee is going to be added as well.
            If the receiver is not a natural address but also a person then she/he will be invited as well.
            
            @_to        For who
            @_amount    Amount
            
            @bool       Was the function successful?
        */
        bytes memory data;
        if ( isContract(_to) ) {
            transferToContract(msg.sender, _to, _amount, data);
        } else {
            transfer_(msg.sender, _to, _amount);
        }
        Transfer(msg.sender, _to, _amount, data);
        return true;
    }
    
    /**
     * @notice Send `_amount` tokens to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address holding the tokens being transferred
     * @param _to The address of the recipient
     * @param _amount The amount of tokens to be transferred
     * @return True if the transfer was successful
     */
    function transferFrom(address _from, address _to, uint256 _amount) isReady external returns (bool) {
        /*
            Launch a transaction where we transfer from a given address to another one. It can only be called by an address which was allowed before.
            Transaction fee will be charged too.
            If the receiver is not a natural address but also a person then she/he will be invited as well
            
            @_from      From who?
            @_to        For who?
            @_amount    Amount
            
            @bool       If the function was successful.
        */
        if ( _from != msg.sender ) {
            allowance_[_from][msg.sender].amount = safeSub(allowance_[_from][msg.sender].amount, _amount);
            allowance_[_from][msg.sender].nonce++;
            AllowanceUsed(msg.sender, _from, _amount);
        }
        bytes memory data;
        if ( isContract(_to) ) {
            transferToContract(_from, _to, _amount, data);
        } else {
            transfer_( _from, _to, _amount);
        }
        Transfer(_from, _to, _amount, data);
        return true;
    }
    
    /**
     * @notice Send `_amount` Corion tokens to `_to` from `msg.sender` and notify the receiver from your transaction with your `_extraData` data
     * @param _to The contract address of the recipient
     * @param _amount The amount of tokens to be transferred
     * @param _extraData Data to give forward to the receiver
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _amount, bytes _extraData) isReady external returns (bool) {
        /*
            Launch a transaction where we transfer from a given address to another one.
            After thetransaction the approvedCorionPremiumToken function of the receiver’s address is going to be called with the given data.
            
            @_to         For who?
            @_amount     Amount
            @_extraData  Extra data that will be given to the receiver
            
            @bool        If the function was successful.
        */
        if ( isContract(_to) ) {
            transferToContract(msg.sender, _to, _amount, _extraData);
        } else {
            transfer_( msg.sender, _to, _amount);
        }
        Transfer(msg.sender, _to, _amount, _extraData);
        return true;
    }
    
    function transferToContract(address _from, address _to, uint256 _amount, bytes _extraData) internal {
        /*
            Inner function in order to transact a contract.
            
            @_to            For who?
            @_amount        Amount
            @_extraData     Extra data that will be given to the receiver
        */
        transfer_(_from, _to, _amount);
        var (success, back) = thirdPartyPContractAbstract(_to).receiveCorionPremiumToken(_from, _amount, _extraData);
        require( success );
        require( _amount > back );
        if ( back > 0 ) {
            transfer_(_to, _from, back);
        }
    }
    
    function transfer_(address _from, address _to, uint256 _amount) isReady internal {
        /*
            Inner function to launch a transaction. The token has been moved so we cherge for the transaction fee as well.
            During the ICO transactions are only possible from the genesis address
            After the transaction the event will be sent to the moduleHandlernek where it is going to be broadcast.
            
            @_from      From how?
            @_to        For who?
            @_amount    Amount
            @_fee       Whether to be charged or not charged with the transaction fee.
        */
        require( _from != 0x00 && _to != 0x00 && _to != 0xa636a97578d26a3b76b060bbc18226d954cf3757 );
        require( ( ! isICO) || genesis[_from] );
        //require( db.decrease(_from, _amount) );
        TEST_dbDecrease(_from, _amount);
        //require( db.increase(_to, _amount) );
        TEST_dbIncrease(_to, _amount);
    }
    
    function mint(address _owner, uint256 _value) external returns (bool) {
        /*
            Generating tokens. It can be called only by ICO contract or the moduleHandler.
            
            @_owner     address
            @_value     amount.
            
            @bool       Was the Function successful?
        */
        require( msg.sender == icoAddr || isICO );
        mint_(_owner, _value);
        return true;
    }
    
    function mint_(address _owner, uint256 _value) isReady internal {
        /*
            Inner function to create a token.
            
            @_owner     Address of crediting the token.
            @_value     Amount
        */
        //require( db.increase(_owner, _value) );
        TEST_dbIncrease(_owner, _value);
        Mint(_owner, _value);
    }
    
    function isContract(address addr) internal returns (bool) {
        /*
            Inner function in order to check if the given address is a natural address or a contract.
            
            @addr       The address which is needed to be checked.
            
            @bool       Is the address crontact or not
        */
        uint codeLength;
        assembly {
            codeLength := extcodesize(addr)
        }
        return codeLength > 0;
    }
    
    function balanceOf(address _owner) constant returns (uint256 _value) {
        /*
            Token balance query
            
            @_owner     address
            @_value     balance of address
        */
        //return db.balanceOf(_owner);
    }
    
    function totalSupply() constant returns (uint256 _value) {
        /*
            Total token quantity query
            
            @_value     Total token quantity
        */
       // return db.totalSupply();
    }
    
    event AllowanceUsed(address indexed spender, address indexed owner, uint256 indexed value);
    event Mint(address indexed addr, uint256 indexed value);
    event Burn(address indexed addr, uint256 indexed value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _extraData);
}