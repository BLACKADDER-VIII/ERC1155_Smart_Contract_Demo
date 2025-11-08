<script lang="ts">
	import { page } from '$app/stores'
	import { get, writable } from 'svelte/store';
    import {ethers} from "ethers";
	import {SFTContract__factory} from "/Users/dhroovpandey/Desktop/web3-sveltekit-bundle/packages/foundry/dist/factories/";
    let private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
	export let data;
    let balance = 0;
	let contract_addr = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
	const token_bal_list = writable([]);
	const token_price_list = writable([]);
	const token_supply_list = writable([]);
	const token_limit_list = writable([]);
	const provider = new ethers.JsonRpcProvider(data.rpcUrl);
	let mint_token:Number;
	let mint_token_amt: Number;
	let burn_token: Number;
	let burn_token_amt: Number;
	let transfer_token: Number;
	let transfer_token_amt: Number;
	let transfer_target_addr: string;
	let sft_convert_token: Number;
	let max_limit_token: Number;
	let max_limit_amt: Number;
	let wallet;
	$: wallet = new ethers.Wallet(private_key, provider);
	let contract:SFTContract__factory;
    const load_balance = async()=>{
        balance = Number(await provider.getBalance(wallet.address))/1e18;
    }
	const connect_contract = async ()=>{
		contract = SFTContract__factory.connect(contract_addr, wallet);
		try{
			await contract.waitForDeployment();
			alert("Contract connected");
			await update_token_chart();
		}
		catch(e){
			alert("Couldn't connect to contract. Check address again.")
		}
	}
	const update_token_chart = async()=>{
		const max_token = Number(await contract.get_max_token());
			const temp_list = [];
			for(let i = 0; i<max_token; i++){
				const token_price = Number(await contract.get_price(i))/1e18;
				temp_list.push(token_price);
			}
			token_price_list.update(current=>[...temp_list]);
			temp_list.length = 0;
			for(let i = 0; i<max_token; i++){
				const token_price = Number(await contract.get_supply(i));
				temp_list.push(token_price);
			}
			token_supply_list.update(current=>[...temp_list]);
			temp_list.length = 0;
			for(let i = 0; i<max_token; i++){
				const token_price = Number(await contract.get_max_supply(i));
				temp_list.push(token_price);
			}
			token_limit_list.update(current=>[...temp_list]);
	}
	const update_token_list = async ()=>{
		const max_token = Number(await contract?.get_max_token());
		console.log("Max token is ", max_token);
		token_bal_list.update(current=>[]);
		for(let i = 0; i<max_token; i++){
			const bal = Number(await contract?.balanceOf(wallet.address, i));
			console.log("Balance received ", bal);
			token_bal_list.update((current) => [...current, {id: i, balance: bal}]);
		}
	}
	const mint = async ()=>{
		try{
			const tx = await contract?.mint(Number(mint_token), Number(mint_token_amt), {value: ethers.parseEther(($token_price_list[mint_token]*mint_token_amt).toString())});
			const rc = await tx.wait();
			alert("Minted Successfully");
		}
		catch(e){
			if(e.reason)
				alert(e.reason);
			else
				alert(e);
		}
	}
	const burn = async ()=>{
		try{
			const tx = await contract?.burn(burn_token, burn_token_amt);
			const rct = tx.wait();
			alert("Succesfully burned");
		}
		catch(e){
			if(e.reason)
				alert(e.reason);
			else
				alert(e);
		}
	}

	const transer = async ()=>{
		try{
			const txt = await contract?.transfer(transfer_target_addr, transfer_token, transfer_token_amt);
			const rct = await txt.wait();
			alert("Transfer successful");
		}
		catch(e){
			if(e.reason)
				alert(e.reason);
			else
				alert(e);
		}
	}

	const make_nft = async ()=>{
		try{
			const txt = await contract?.make_non_fungible(sft_convert_token);
			const rct = await txt.wait();
			alert("SFT converted to NFT");
		}
		catch(e){
			if(e?.reason)
				alert(e?.reason);
			else
				alert(e);
		}
	}

	const set_max_limit = async () =>{
		try{
			const txt = await contract?.set_max_supply(max_limit_token, max_limit_amt);
			const rct = txt.wait();
			alert("Successfully set new limit");
		}
		catch(e){
			if(e?.reason)
				alert(e.reason);
			else
				alert(e);
		}
	}

	const withdraw = async ()=>{
		try{
			const txt = await contract?.withdraw();
			const rct = await txt.wait();
			alert("Successfully withdrawn funds");
		}
		catch(e){
			if(e?.reason)
				alert(e.reason);
			else
				alert("Only owner can withdraw");
		}
	}
	
</script>

<span class="flex justify-center bg-violet-300 text-xl font-bold text-green-700"> 
    Your account balance: {balance} ETH
</span>
<div class="flex  justify-center bg-indigo-400">
<button on:click={load_balance} class="rounded-xl p-1 text-xl bg-blue-400 hover:outline-none hover:bg-indigo-400">
    Load balance
</button>
</div>
<div class="grid grid-cols-3 gap-6 bg-purple-400 p-4">
	<span class="text-blue-100 p-2 text-xl">Enter Contract Address: </span>
	<input on:input={(ev)=>{contract_addr = ev.target?.value;}}/>
	<button on:click={connect_contract} class="p-1 rounded-xl bg-blue-500 outline outline-black font-medium hover:outline-none hover:bg-blue-300">Connect Contract</button>
</div>
<div class="grid grid-cols-2 bg-indigo-400 p-2">
	<span class="text-blue-100 p-2 text-xl">Enter Private Key: </span>
	<input on:input={(ev)=>{private_key = ev.target?.value;}}/>
</div>
<div class="grid grid-cols-3">

<div class="grid bg-cyan-500 justify-items-center text-center h-64">
	<label class="text-xl font-bold text-green-800 p-3">Your token balance</label>
	<button on:click={update_token_list} class="rounded-xl w-full bg-cyan-600 text-white outline outline-black font-medium hover:bg-cyan-300 hover:outline-none hover:text-black">Update Token List</button>
	<ul class="mt-2 max-h-64 overflow-y-auto border border-gray-300 bg-green-100 w-full">
		<li class="grid grid-cols-2">
			<strong>Token ID </strong> <strong class="text-green-700">Balance</strong>
		</li>
		{#each $token_bal_list as d}
		<li class="grid grid-cols-2">
			<strong>{d.id}: </strong> <span class="text-green-700">{d.balance}</span>
		</li>
		{/each}
	</ul>
</div>

<div class="bg-yellow-400 p-1">
	<div class="grid grid-cols-2">
	<strong>Enter Token to mint</strong> <input type="number" on:input={(ev)=>{mint_token = Number(ev.target?.value);}}/>
	<strong>Enter amount to mint</strong> <input type="number" on:input={(ev)=>{mint_token_amt=Number(ev.target?.value);}}/>
	<button class="bg-zinc-400 col-span-2 font-bold outline outline-black p-2 rounded hover:bg-zinc-150 hover:outline-none" on:click={mint}>Mint</button>
	</div>
	<div class="grid grid-cols-2 bg-red-400">
	<strong>Enter Token to burn</strong> <input type="number" on:input={(ev)=>{burn_token = Number(ev.target?.value);}}/>
	<strong>Enter amount to burn</strong> <input type="number" on:input={(ev)=>{burn_token_amt=Number(ev.target?.value);}}/>
	<button class="bg-zinc-400 col-span-2 font-bold outline outline-black p-2 rounded hover:bg-zinc-150 hover:outline-none" on:click={burn}>Burn</button>
	</div>
</div>

<div class="grid grid-cols-3 p-1 bg-green-300">
	
	<div>
	<label class="text-l font-bold text-red-400 p-1">Token prices</label>
	<ul class="max-h-64">
		{#each $token_price_list as t, ind}
		<li>
			<strong>{ind}:</strong> <strong class="text-zinc-500">{t}</strong> ETH
		</li>
		{/each}
	</ul>
	</div>

	<div>
	<label class="text-l font-bold text-red-400 p-1">Token Supply</label>
	<ul class="max-h-64">
		{#each $token_supply_list as t, ind}
		<li>
			<strong>{ind}:</strong> <strong class="text-zinc-500">{t}</strong>
		</li>
		{/each}
	</ul>
	</div>

	<div>
	<label class="text-l font-bold text-red-400 p-1">Token limit</label>
	<ul class="max-h-64">
		{#each $token_limit_list as t, ind}
		<li>
			<strong>{ind}:</strong> <strong class="text-zinc-500">{t}</strong>
		</li>
		{/each}
	</ul>
	</div>
	<button class = "col-span-3 font-bold rounded text-xl bg-blue-500 text-white hover:bg-blue-200 hover:text-black" on:click={update_token_chart}>Referesh Tokens Chart</button>
</div>
</div>
<div class="grid grid-cols-3 gap-1">
	<strong>Token ID</strong> <strong>Token Amount</strong> <strong>Recepient Address</strong>
	<input class="outline outline-none hover:outline-blue-400" on:input={(ev)=>{transfer_token=Number(ev.target?.value);}}/>
	<input class="outline outline-none hover:outline-blue-400" on:input={(ev)=>{transfer_token_amt=Number(ev.target?.value);}}/>
	<input class="outline outline-none hover:outline-blue-400" on:input={(ev)=>{transfer_target_addr=ev.target?.value;}}/>
	<button class="col-span-3 bg-blue-600 outline outline-black rounded p-2 text-xl font-bold text-white hover:outline-none hover:bg-blue-400 hover:text-black" on:click={transer}>Transfer</button>
</div>
<div class="p-1 grid grid-cols-3 bg-red-400">
	<strong class="col-span-3">Owner Only</strong>
<div class="grid grid-cols-2">
	<strong class="text-center text-xl p-1 bg-violet-400">SFT ID</strong> <input type="number" on:input={(ev)=>{sft_convert_token = Number(ev.target?.value);}}/>
	<button class="col-span-2 font-bold rounded text-xl bg-yellow-400 text-red-600 outline outline-black hover:outline-none hover:bg-yellow-200 hover:text-red-300" on:click={make_nft}>Make NFT</button>
</div>
<button class="bg-green-500 font-bold text-xl text-white hover:bg-green-300 hover:text-black" on:click={withdraw}>Withdraw</button>
<div class="grid grid-cols-2">
	<strong class="font-bold text-xl text-center p-1 bg-indigo-400">Token ID</strong> <input type="number" on:input={(ev)=>{max_limit_token = Number(ev.target?.value);}}/>
	<strong class="font-bold text-xl text-center p-1 bg-indigo-400">New Supply Limit</strong> <input type="number" on:input={(ev)=>{max_limit_amt = Number(ev.target?.value);}}/>
	<button class="col-span-2 rounded text-xl font-bold bg-orange-500 text-white hover:bg-orange-300 hover:text-black" on:click={set_max_limit}>Set Max Limit</button>
</div>
</div>
