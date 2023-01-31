import React, { useState } from 'react';
import { useEffect } from 'react';
import { useRouter } from 'next/router';
import { ethers } from 'ethers';
import { abi, contractAddress } from './constants'