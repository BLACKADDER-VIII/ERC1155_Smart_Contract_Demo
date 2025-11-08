// import Counter from "./out/Counter.sol/Counter.json"
// export {Counter}
import { runTypeChain, glob } from 'typechain'
//import fs from "fs"
//import path from "path"

//Assumes each file has one contract and file names and contract names are identical 
const contractNames = ["SFTContract"];


async function main() {
  const cwd = process.cwd()
  // find all files matching the glob
  //const allFiles = glob(cwd, [`${config.paths.artifacts}/!(build-info)/**/+([a-zA-Z0-9_]).json`])
  const allFiles = contractNames.map((name) => `./out/${name}.sol/${name}.json`)
  const result = await runTypeChain({
    cwd,
    filesToProcess: allFiles,
    allFiles,
    outDir: './dist',
    target: 'ethers-v6',
  })
}

main().catch(console.error)