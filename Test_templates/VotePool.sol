pragma solidity ^0.4.11;


/**
 * @title Token contract to call COR functions.
 */
contract Token {
    function transfer(address to, uint256 amount) external returns (bool success) { }
}

/**
 * @title moduleHandler contract of Corion platform.
 */
contract ModuleHandler {
    function publicAddOwner(address addr) external {}
}



/** 
 * 
 * @title Vote Pool contract to execute community votes
 * 
 * @dev This contract represents a possibility to elect a new owner from a proposal pool
 *  by the community decision.
 * 
 * 
 *  Everyone is allowed to deposit any amount of COR at any time.
 * 
 *  Everyone is allowed to withdraw his (her) deposit at any time.
 * 
 *  Everyone is allowed to execute a targeted proposal at any time. If there will be
 *  enough COR tokens at the moment of execution then the proposal
 *  will be successfully evaluated.
 *  After the evaluation of the proposal every participant should withdraw his (her) COR tokens.
 * 
 * 
 * 
 *  HOW TO elect a new owner.
 * 
 * 1. Choose a community member who deserves to be one of the owners of the CORION platform.
 * 
 * 2. Deploy this contract. Input valid COR token contract address,
 * CORION moduleHandler contract address
 * and the address of the desired member of the community who will become the owner.
 * 
 * 3. Deposit COR into this contract.
 * 
 * 4. Evaluate a proposal. Call `evaluate_New_Owner_Election`.
 * If there will be enough COR tokens at the balance of this contract
 * then the proposal will be successfully evaluated
 * and desired member of the community will become the owner.
 * (75% of total COR supply is required by default)
 * 
 * 5. Withdraw remaining COR.
 * There is no need to keep it here if the proposal was successfully evaluated.
 */

contract VotePool {
    
    /** @variable Corion_token_contract Address of contract of COR token. */
    address public Corion_token_contract;
    
    /** @variable moduleHandlerAddress Address of contract of Corion `moduleHandler`. */
    address public moduleHandlerAddress;
    
    /** @variable election_Target This address will become owner
     * if the proposal of this contract will be successfully evaluated 
     */
    address public election_Target;
    
    /** @variable balances Stores a deposits of each user to refund them
     * if they want to withdraw their COR tokens
     */
    mapping (address => uint256) public balances;
    
    
    // Throw the fallbacks.
    function() {
        throw;
    }
    function tokenFallback(address,uint256,bytes) {
        throw;
    }
    ///////
    
    
    /** 
     * Constructor.
     * @param _Corion_token_contract This address will be allowed to send deposits
     * into Vote Pool. Only COR tokens should be deposited, other tokens should be rejected.
     * 
     * @param _moduleHandlerAddress  This contract will be called
     * to evaluate new owner election.
     */
    function VotePool(address _Corion_token_contract, address _moduleHandlerAddress) {
        Corion_token_contract = _Corion_token_contract;
        moduleHandlerAddress  = _moduleHandlerAddress;
    }
    
    /**
     * @return _target Address that will be proposed to become one of the owners
     * of Corion platform.
     */
    function getElectionTarget() constant returns (address _target) {
        return election_Target;
    }
    
    /**
     * @dev COR token fallback function.
     * 
     * @param _from The address that deposits COR tokens.
     * @param _value Amount of tokens that were deposited.
     * @param _data Additional data. Not used here.
     * 
     * @return bool If the function was successfully executed return `true`.
     * @return uint256 Amount of tokens that you want to send back. 
     * In this contract, the total amount of deposited tokens will be accepted.
     * It will not reject anything.
     */
    function receiveCorionToken(address _from, uint256 _value, bytes _data) external returns (bool, uint256) {
        // If this function was not called by the COR token contract, throw
        // because of no real COR tokens were deposited.
        if(msg.sender != Corion_token_contract) { throw; }
        balances[_from] += _value;
        return (true, 0);
    }
    
    
    /**
     * @dev User should call this function if he wants to withdraw tokens from this contract.
     */
    function give_My_Tokens_Back() {
        Token tkn = Token(Corion_token_contract);
        if(tkn.transfer(msg.sender, balances[msg.sender])) {
            balances[msg.sender] = 0; 
        }
    }
    
    /**
     * @dev Anyone can call this function. If there will be enough COR tokens in this contract
     * at the moment of function execution then the proposal will be successfully evaluated
     * and `election_Target` will become one of the owners of Corion platform.
     */
    function evaluate_New_Owner_Election() {
        ModuleHandler moduleHandler = ModuleHandler(moduleHandlerAddress);
        moduleHandler.publicAddOwner(election_Target);
    }
    
    
}
