import IPFS from 'ipfs-http-client'

require("dotenv").config()

const ipfs = new IPFS({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    apiKey: process.env.IPFS_API_KEY
  })