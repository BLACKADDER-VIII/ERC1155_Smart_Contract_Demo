pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract SFTContract is ERC1155, Ownable {
    using Strings for uint256;

    uint256 public constant fung_1 = 0;
    uint256 public constant fung_2 = 1;
    uint256 public constant nft_1 = 2;
    uint256 public constant nft_2 = 3;
    uint256 public constant sft_1 = 4;
    uint256 public constant sft_2 = 5;
    uint256 private curr_token_num = 6;
    mapping(uint256=>uint256) total_supply;
    mapping(uint256=>uint256) max_supply_map; 
    mapping(uint256=>uint256) private token_type; 
    mapping(uint256=>uint256) token_price_map; 
    mapping(uint256=>bool) token_exists;
    mapping(uint256=>address[]) private sft_holders;

    constructor(string memory baseURI) ERC1155(baseURI) Ownable(msg.sender) {
        _mint(msg.sender, fung_1, 100, "");
        _mint(msg.sender, fung_2, 200, "");
        _mint(msg.sender, nft_1, 1, "");
        _mint(msg.sender, nft_2, 1, "");
        _mint(msg.sender, sft_1, 10, "");
        _mint(msg.sender, sft_2, 15, "");
        total_supply[fung_1] = 100;
        total_supply[fung_2] = 200;
        total_supply[nft_1] = 1;
        total_supply[nft_2] = 1;
        total_supply[sft_1] = 10;
        total_supply[sft_2] = 15;
        max_supply_map[fung_1] = 200;
        max_supply_map[fung_2] = 300;
        max_supply_map[nft_1] = 1;
        max_supply_map[nft_2] = 1;
        max_supply_map[sft_1] = 15;
        max_supply_map[sft_2] = 25;
        token_type[fung_1] = 0;
        token_type[fung_2] = 0;
        token_type[nft_1] = 1;
        token_type[nft_2] = 1;
        token_type[sft_1] = 2;
        token_type[sft_2] = 2;
        token_price_map[fung_1] = 2 ether;
        token_price_map[fung_2] = 1 ether;
        token_price_map[nft_1] = 20 ether;
        token_price_map[nft_2] = 40 ether;
        token_price_map[sft_1] = 5 ether;
        token_price_map[sft_2] = 8 ether;
        token_exists[fung_1] = true;
        token_exists[fung_2] = true;
        token_exists[nft_1] = true;
        token_exists[nft_2] = true;
        token_exists[sft_1] = true;
        token_exists[sft_2] = true;
        sft_holders[sft_1].push(msg.sender);
        sft_holders[sft_2].push(msg.sender);
    }

    modifier exists(uint256 id) {
        require(token_exists[id], "Token doesn't exist");
        _;
    }

    function set_max_supply(uint256 tokenid, uint256 new_limit) public onlyOwner exists(tokenid){
        require(token_type[tokenid]!=1, "NFT token supply limit can't be changed");
        require(new_limit >= total_supply[tokenid], "There are more tokens in circulation than new limit. Destroy some tokens first.");
        max_supply_map[tokenid] = new_limit;
    }

    function modify_price(uint256 tokenid, uint256 new_price) public onlyOwner exists(tokenid){
        token_price_map[tokenid] = new_price * 1 ether;
    }

    function get_price(uint256 tokenid) external exists(tokenid) view returns (uint256) {
        return token_price_map[tokenid];
    }

    function mint(uint256 tokenid, uint256 amount) external exists(tokenid) payable{
        require(msg.value >= token_price_map[tokenid]*amount, string.concat("Not enough ETH sent, needed: ", Strings.toString(token_price_map[tokenid]*amount), "Sent: ", msg.value.toString()));
        require(total_supply[tokenid]+amount<=max_supply_map[tokenid], "Max supply exceeded!");
        _mint(msg.sender, tokenid, amount, "");
        total_supply[tokenid] += amount;
        if(token_type[tokenid]==2){ // Is SFT, minter needs to be added to holders to later modify account
            bool is_in = false;
            for(uint256 i = 0; i<sft_holders[tokenid].length; i++){
                if(sft_holders[tokenid][i] == msg.sender){
                    is_in = true;
                    break;
                }
            }
            if(!is_in)
                sft_holders[tokenid].push(msg.sender);
        }
    }

    function burn(uint256 tokenid, uint256 amount) external exists(tokenid) {
        _burn(msg.sender, tokenid, amount);
        total_supply[tokenid] -= amount; 
        if(token_type[tokenid]==2){     // SFT: might need to update holders list for efficiency
            if(balanceOf(msg.sender, tokenid)==0){  // Isn't an SFT holder anymore, needs to be removed
                for(uint256 i = 0; i<sft_holders[tokenid].length; i++){
                    if(sft_holders[tokenid][i] == msg.sender){
                        sft_holders[tokenid][i] = sft_holders[tokenid][sft_holders[tokenid].length-1];
                        sft_holders[tokenid].pop();
                        return;
                    }
                }
            }
        }       
    }

    function transfer(address target, uint256 tokenid, uint256 amount) external exists(tokenid) {
        safeTransferFrom(msg.sender, target, tokenid, amount, "");
        if(token_type[tokenid]==2){     // SFT: might need to update holders list for efficiency
            bool is_in = false;
            for(uint256 i = 0; i<sft_holders[tokenid].length; i++){
                if(sft_holders[tokenid][i] == target){
                    is_in = true;
                    break;
                }
            }
            if(!is_in)
                sft_holders[tokenid].push(target);
            if(balanceOf(msg.sender, tokenid)==0){  // Isn't an SFT holder anymore, needs to be removed
                for(uint256 i = 0; i<sft_holders[tokenid].length; i++){
                    if(sft_holders[tokenid][i] == msg.sender){
                        sft_holders[tokenid][i] = sft_holders[tokenid][sft_holders[tokenid].length-1];
                        sft_holders[tokenid].pop();
                        return;
                    }
                }
            }
        }     
    }

    function make_non_fungible(uint256 tokenid) external exists(tokenid) onlyOwner {
        require(token_type[tokenid]==2, "Token is not semi-fungible");
        token_type[tokenid] = 1;
        uint256 balance = balanceOf(msg.sender, tokenid);
        _burn(msg.sender, tokenid, balance);
        _mint(msg.sender, tokenid, 1, "");
        for(uint256 i = 0; i<sft_holders[tokenid].length; i++){
            address a = sft_holders[tokenid][i];
            uint256 num_toks = balanceOf(a, tokenid);
            _burn(a, tokenid, num_toks);
            for(uint256 j = 0; j<num_toks; j++){    // Minting new NFTs for the SFT
                _mint(a, curr_token_num, 1, "");
                token_exists[curr_token_num] = true;
                max_supply_map[curr_token_num] = 1;
                token_type[curr_token_num] = 1;
                token_price_map[curr_token_num] = token_price_map[tokenid];
                total_supply[curr_token_num] = 1;
                curr_token_num++;
            }
        }
        delete sft_holders[tokenid];
        total_supply[tokenid] = 0;
    }

    function withdraw() external onlyOwner {
        (bool succ, ) = owner().call{value: address(this).balance}("");
        require(succ, "Withdrawal failed");
    }

    function get_max_token() external view returns (uint256){
        return curr_token_num;
    }

    function get_supply(uint256 tokenid) external exists(tokenid) view returns(uint256) {
        return total_supply[tokenid];
    }

    function get_max_supply(uint256 tokenid) external exists(tokenid) view returns (uint256) {
        return max_supply_map[tokenid];
    }
}