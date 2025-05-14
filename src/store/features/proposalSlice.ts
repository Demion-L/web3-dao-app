// const proposalSlice = createSlice({
//   name: 'proposal',
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
//     },
//     fetchVotesFailure: (state, action) => {
//       state.isLoading = false;
//       state.error = action.payload;
//     }
//   },    
//     extraReducers: (builder) => {
//         builder.addCase(fetchProposals.fulfilled, (state, action) => {
//         state.isLoading = false;
//         state.proposals = action.payload;
//         });
//         builder.addCase(fetchVotes.fulfilled, (state, action) => {
//         state.isLoading = false;
//         state.votes = action.payload;
//         });
//     }
//     },
// });
// export const {
//   fetchProposalsStart,
//   fetchProposalsSuccess,
//   fetchProposalsFailure,
//   fetchVotesStart,
//   fetchVotesSuccess,
//   fetchVotesFailure,
// } = proposalSlice.actions;
// export default proposalSlice.reducer;
// export const selectProposals = (state) => state.proposal.proposals;
// export const selectVotes = (state) => state.proposal.votes;
// export const selectIsLoading = (state) => state.proposal.isLoading;
// export const selectError = (state) => state.proposal.error;
// export const fetchProposals = createAsyncThunk(
//   'proposal/fetchProposals',
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