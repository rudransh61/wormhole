module Wormhole::VAA{
    use 0x1::vector;
    use Wormhole::Deserialize;
    use Wormhole::Serialize;

    struct VAA has key {
            // Header
            version:            u8,
            guardian_set_index: u64,
            signatures:         vector<vector<u8>>,
            
            // Body
            timestamp:          u64,
            nonce:              u64,
            emitter_chain:      u64,
            emitter_address:    vector<u8>,
            sequence:           u64,
            consistency_level:  u8,
            payload:            vector<u8>,
    }

    public fun parse(bytes: vector<u8>): VAA {
        let (version, bytes) = Deserialize::deserialize_u8(bytes);
        let (guardian_set_index, bytes) = Deserialize::deserialize_u64(bytes);

        let (signatures_len, bytes) = Deserialize::deserialize_u8(bytes);
        let signatures = vector::empty<vector<u8>>();

        assert!(signatures_len <= 19, 0); 

         while ({
            spec { 
                invariant signatures_len >  0; 
                invariant signatures_len <= 19; 
            };
            signatures_len > 0
        }) {
            let (signature, _) = Deserialize::deserialize_vector(bytes, 32);
            vector::push_back(&mut signatures, signature);
            signatures_len = signatures_len - 1;
        };

        let (timestamp, bytes) = Deserialize::deserialize_u64(bytes);
        let (nonce, bytes) = Deserialize::deserialize_u64(bytes);
        let (emitter_chain, bytes) = Deserialize::deserialize_u64(bytes);
        let (emitter_address, bytes) = Deserialize::deserialize_vector(bytes, 20);
        let (sequence, bytes) = Deserialize::deserialize_u64(bytes);
        let (consistency_level, bytes) = Deserialize::deserialize_u8(bytes);
        let remaining_length = vector::length(&bytes);
        let (payload, _) = Deserialize::deserialize_vector(bytes, remaining_length);

        VAA {
            version:            version,
            guardian_set_index: guardian_set_index,
            signatures:         signatures,
            timestamp:          timestamp,
            nonce:              nonce,
            emitter_chain:      emitter_chain,
            emitter_address:    emitter_address,
            sequence:           sequence,
            consistency_level:  consistency_level,
            payload:            payload,
        }
    }

    public fun get_payload(vaa: &mut VAA): vector<u8>{
         vaa.payload
    }

    public fun destroy(vaa: VAA): vector<u8>{
         let VAA {
            version,
            guardian_set_index,
            signatures,
            timestamp,
            nonce,
            emitter_chain,
            emitter_address,
            sequence,
            consistency_level,
            payload,
         } = vaa;
         //(id, version, guardian_set_index, signatures, timestamp, nonce, emitter_chain, emitter_address, sequence, consistency_level, payload)
        payload
    }

    //TODO: verify vaa
    //public fun verify(vaa: &VAA){//, guardian_set: &GuardianSet::GuardianSet) {
        // let index = 0;
        // let hash = hash(vaa);
        // let n = vector::length<vector<u8>>(&vaa.signatures);
        // let i = 0;
        // loop {
        //     if (i==n){
        //         break;
        //     };
        //     // TODO: secp256k_ecrecover AND secp256k_verify
        //     //let pubkey = secp256k_ecrecover(&signature);
        //     //assert!(expected_signers[i] == pubkey, 0);
        //     //secp256k_verify(&signature, &pubkey, &hash);
        //     i = i + 1;
        // }
    //}
    
    fun hash(vaa: &VAA): vector<u8> {
        use 0x1::hash;

        let bytes = vector::empty<u8>();
        Serialize::serialize_u64(&mut bytes, vaa.timestamp);
        Serialize::serialize_u64(&mut bytes, vaa.nonce);
        Serialize::serialize_u64(&mut bytes, vaa.emitter_chain);
        Serialize::serialize_vector(&mut bytes, vaa.emitter_address);
        Serialize::serialize_u64(&mut bytes, vaa.sequence);
        Serialize::serialize_u8(&mut bytes, vaa.consistency_level);
        Serialize::serialize_vector(&mut bytes, vaa.payload);
        
        hash::sha3_256(bytes)
    }





}





