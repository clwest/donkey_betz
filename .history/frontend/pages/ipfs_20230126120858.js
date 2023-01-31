import IPFS from 'ipfs-http-client'

require("dotenv").config()

const ipfs = new IPFS({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    apiKey: "YOUR_API_KEY_HERE"
  })