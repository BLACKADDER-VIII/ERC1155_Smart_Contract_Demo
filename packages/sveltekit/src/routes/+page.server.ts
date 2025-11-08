import {ethers} from "ethers";
import type {PageServerLoad} from './$types';


const load : PageServerLoad = async(data) =>{
	const rpcUrl = "http://localhost:8545";
	return {rpcUrl};
}