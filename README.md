# ERC 1155 Contract UI plus Backend

## Installation
- Run `pnpm install`

## Running the app
- Launch the blockchain using `pnpm anvil`
- Open a new terminal and build the contract, create typings and deploy to the anvil blockchain using:
```
pnpm forge:build    // To compile and create typings
pnpm forge:create src/SFTContract.sol:SFTContract http://localhost:9090     // To deploy
```
- Run the following to serve the token info directory
```
cd ./packages/foundry/src/tokens_json; python3 -m http.server 9090
```
- Finally, open another terminal and use `pnpm dev` to run the UI