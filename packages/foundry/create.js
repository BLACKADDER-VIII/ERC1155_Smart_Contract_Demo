import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import util from 'node:util';
import {exec} from "node:child_process"
const execP = util.promisify(exec);
import 'dotenv/config';

const {RPC_URL, PRIVATE_KEY} = process.env;
const {argv} = process;
const re = new RegExp('^Deployed to: .+', 'm');


async function lsExample() {
  const contract = argv[2];
  const { stdout, stderr } = await execP(`forge create --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY}  ${contract}  --broadcast --constructor-args ${argv[3]}` );
  // console.log('stdout:', stdout);
  if(stderr) {
      console.error('stderr:', stderr);
  } else {
    const m = stdout.match(re)
    const address = m && m[0].replace("Deployed to: ", "");
    const obj = {[contract]: address}
    try {
      const filePath = resolve('./contract_address.json');
      let caobj = await readFile(filePath, { encoding: 'utf8' });
      caobj = JSON.parse(caobj);
      //overwrite previous address of the contract
      caobj = {...caobj, ...obj}
      console.log('updating contract_address.json')
      console.log(JSON.stringify(obj))
      await writeFile('contract_address.json', `${JSON.stringify(caobj)}\n`);
    } catch(e) {
      //console.log(e);
      console.log('creating contract_address.json')
      await writeFile('contract_address.json', JSON.stringify(obj));  
    }
  }
  // console.log(argv)
}

//"forge create --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 src/Counter.sol:Counter",

lsExample();