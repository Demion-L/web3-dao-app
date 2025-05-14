// const governanceSlice = {
//   name: 'governance',
//   initialState: {
//     proposals: [],
//     votes: [],
//     isLoading: false,
//     error: null,
//   },
//   reducers: {
//     fetchProposalsStart: (state) => {
//       state.isLoading = true;
//       state.error = null;
//     }
//     fetchProposalsSuccess: (state, action) => {
//       state.isLoading = false;
//       state.proposals = action.payload; 
//     },
//     fetchProposalsFailure: (state, action) => {
//       state.isLoading = false;
//       state.error = action.payload;
//     }
//     fetchVotesStart: (state) => {
//       state.isLoading = true;
//       state.error = null;
//     },
//     fetchVotesSuccess: (state, action) => {
//       state.isLoading = false;
//       state.votes = action.payload;
//     }
//     fetchVotesFailure: (state, action) => {
//       state.isLoading = false;
//       state.error = action.payload;
//     }
//   },
//   extraReducers: (builder) => {
//     builder.addCase(fetchProposals.fulfilled, (state, action) => {
//       state.isLoading = false;
//       state.proposals = action.payload;
//     });
//     builder.addCase(fetchVotes.fulfilled, (state, action) => {
//       state.isLoading = false;
//       state.votes = action.payload;
//     });
//   }
// },
// };
// export const {
//   fetchProposalsStart,
//   fetchProposalsSuccess,
//   fetchProposalsFailure,
//   fetchVotesStart,
//   fetchVotesSuccess,
//   fetchVotesFailure,
// } = governanceSlice.actions;
// export default governanceSlice.reducer; 
// export const selectProposals = (state) => state.governance.proposals;
// export const selectVotes = (state) => state.governance.votes;
// export const selectIsLoading = (state) => state.governance.isLoading;
// export const selectError = (state) => state.governance.error;
// export const fetchProposals = createAsyncThunk(
//   'governance/fetchProposals',
//   async (contract) => {
//     const proposals = await contract.getProposals();
//     return proposals;
//   }
// );
// export const fetchVotes = createAsyncThunk(
//   'governance/fetchVotes',
//   async (contract) => {
//     const votes = await contract.getVotes();
//     return votes;
//   }
// );
// export const fetchProposals = createAsyncThunk(
//   'governance/fetchProposals',
//   async (contract, { dispatch }) => {
//     dispatch(fetchProposalsStart());
//     try {
//       const proposals = await contract.getProposals();       
//       dispatch(fetchProposalsSuccess(proposals));
//     } catch (error) {
//       dispatch(fetchProposalsFailure(error.message));
//     }
//   }
// );
// export const fetchVotes = createAsyncThunk(
//   'governance/fetchVotes',
//   async (contract, { dispatch }) => {
//     dispatch(fetchVotesStart());
//     try {
//       const votes = await contract.getVotes();
//       dispatch(fetchVotesSuccess(votes));
//     } catch (error) {
  //    dispatch(fetchVotesFailure(error.message));
//     }
//   }
// );
// );