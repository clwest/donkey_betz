import React, { useState } from 'react';
import { useEffect } from 'react';
import { useRouter } from 'next/router';
import { ethers } from 'ethers';
import { abi, contractAddress } from './constants'

const Signup = () => {
    // Use the useState hook to create state variables for the form input
    const [email, setEmail] = useState('');
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const router = useRouter();
  
    // Use the useEffect hook to create a side effect that will handle the form submission
    useEffect(() => {
      // Create an instance of the ethers.js provider
      const provider = new ethers.providers.JsonRpcProvider('https://ropsten.infura.io/v3/YOUR-PROJECT-ID');
      // Create an instance of the ethers.js Wallet
      const privateKey = 'YOUR_PRIVATE_KEY';
      const wallet = new ethers.Wallet(privateKey, provider);
      // Create an instance of the smart contract
      const contract = new ethers.Contract(contractAddress, abi, wallet);
      
      // handle form submission
      async function handleSubmit(event) {
        event.preventDefault()
        try {
          // encrypt the password
          const encryptedPassword = await encrypt(password);
          // call the smart contract's function to create a new user account
          await contract.register(email, username, encryptedPassword);
          // navigate to the login page
          router.push('/login')
        } catch (err) {
          setErrorMessage(err.message)
        }
        }
        }, []);

        };
        
        export default Signup;

        
        
        
        