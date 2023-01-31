import React, { useState } from 'react'
import { useRouter } from 'next/router'
import { ethers } from 'ethers'
import { ipfs } from './ipfs'
import { abis, contractAddresses } from './constants'

const SignupPage = () => {
  const router = useRouter()
  const [address, setAddress] = useState('')
  const [username, setUsername] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errorMessage, setErrorMessage] = useState('')

  const handleSignup = async (event) => {
    event.preventDefault()
    try {
      // Check if the entered address is a valid Ethereum address
      ethers.utils.getAddress(address)
      
      // Connect to the Users contract
      const provider = new ethers.providers.JsonRpcProvider()
      const signer = provider.getSigner()
      const users = new ethers.Contract(contractAddresses.users, abis.users, signer)

      // Store the user data on IPFS
      const data = { username, email, password }
      const dataBuffer = Buffer.from(JSON.stringify(data))
      const ipfsHash = await ipfs.add(dataBuffer)

      // Mint a soul-bound NFT for the user
      const tx = await users.mint(address, ipfsHash)
      await tx.wait()

      // Redirect the user to the dashboard
      router.push('/dashboard