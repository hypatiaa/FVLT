# FVLT Lean source index

This index covers 1,278 Lean file paths. It includes theorem modules, statement checks, assembly fragments, and historical copies. Each citation opens the named Lean declaration or source line.

[Search the public index](https://hypatiaa.github.io/FVLT/lean/) · [FVLT guide](https://hypatiaa.github.io/FVLT/)

## What the declarations establish

- Exact conductors · Möbius inversion recovers the conductor contribution from folded sums. [E_full_eq_moebius_F_fold](theorems/FVLTConductorProjectorsV1.lean#L505)

- FF-1 · Ford tangency is equivalent to Farey adjacency for distinct rational addresses. [ford_tangent_iff](theorems/FVLTFordGeometryCompletionV1.lean#L158)

- FF-2 · The local link on the atom skin is a cycle. [link_cycle](theorems/FVLTAtomSkinCountsV1.lean#L542)

- FF-3 · Certificate for tangent endpoints of a path with lifted Ford data. [tangent_endpoint_certificate](theorems/FVLTRosetteFordEndpointsV1.lean#L72)

- FF-4 · The quadratic parameter realizes the specified fixed-point multiplier. [parameter_multiplier](theorems/FVLTFordBulbParameterV1.lean#L11)

- Crystal strings · The explicit strings for Div(720). The same file checks the exponent boxes for 30030 and 720720. [N720_strings_values](projects/crystal-strings/SCD_9_7j_1_L01_L03_V1.lean#L370)

- Crystal rank · One raising step increases rank by one for general exponent lists. A general symmetric-chain decomposition is outside the scope of this file. [raise_succ_rank](projects/crystal-strings/SCD_9_7j_1_L01_L03_V1.lean#L270)

- Y-reflection · Reflection of an exponential in the π convention. [reflect_exp_pi](theorems/FVLTYReflectionV1.lean#L115)

- Sign of n₆ · The condition under which a sign flip gives a half-turn. [sign_flip_halfturn_iff](theorems/FVLTN6YReflectionV1.lean#L73)

- Pen · The frequency-one endpoint connects the finite pen to the Möbius function. [pen_one_frequency_one](projects/pen-gauss/FVLT/PenGaussV1.lean#L10)

- Gauss sums · The quadratic pen square at a prime-field order congruent to one modulo four. [quadPen_sq_of_mod_four_eq_one](projects/pen-gauss/FVLT/PenGaussFieldV1.lean#L186)

- Prime phases · The mean squared magnitude of the polynomial equals its arithmetic energy. [norm_sq_D_eq_energy](projects/arithmetic-fourier-rh/CoherentEnergyMeasure.lean#L1613)

- RH criterion · For each fixed B ≥ 1, the energy growth bound for every δ > 0 is equivalent to RH. [coherent_energy_measure_growth_iff_RH](projects/arithmetic-fourier-rh/CoherentEnergyRHBridge.lean#L38)

- Farey energy · The rank-displacement energy equals one twelfth of the coherent arithmetic energy at B = 1. [franelEnergy_eq_coherent_energy](projects/farey-character-bridge/FranelEnergy.lean#L12)

- Two triangles at q = 7 · The orbit phasors add to −1. For the Farey rank errors, the normalized difference of the triangle totals equals a quadratic-character Mertens sum at every order. [Phasor identity](projects/farey-orbit-contrast/FareyOrbitPhasors.lean#L21) · [Farey coefficient](projects/farey-orbit-contrast/FareyQuadraticProjection.lean#L63) · [Replay](projects/farey-orbit-contrast/NUCLEUS_REPLAY.log)

- All characters at prime denominators · The squared Farey rank errors split exactly into character energies. [All-character theorem](projects/farey-prime-character-energy/FareyPrimeCharacterFormula.lean#L79) · [Endpoint correction](projects/farey-prime-character-energy/FareyPrimeCharacterParity.lean#L91) · [Replay](projects/farey-prime-character-energy/NUCLEUS_REPLAY.log)

- Denominator band · Square-root-scale cancellation of the untwisted band implies RH. Proving that cancellation independently remains open in this project. [riemannHypothesis_of_V_cancellation](projects/farey-character-bridge/CrystalBridge.lean#L823)

- Three-tooth Vernier · For every Dirichlet character and X ≥ 2, the centered three-tooth endpoint equals twice the twisted denominator-band sum. [threeToothEndpoint_eq_two_mul_twistedV](projects/farey-character-bridge/ThreeToothVernierBridge.lean#L437)

- Dirac rank · For any coupling of the positive and negative band rows, the Dirac kernel dimension bounds the signed imbalance. Proving a square-root-scale rank deficit at every sufficiently large cutoff remains open. [norm_V_le_dirac_ker](projects/farey-character-bridge/VernierPairingDirac.lean#L679) · [riemannHypothesis_of_dirac_rank_bound](projects/farey-character-bridge/VernierPairingDirac.lean#L689)

- Characters · Twisted band cancellation is equivalent to the every-character zero-free statement. [allChiVCancellation_iff_everyCharacter](projects/farey-character-bridge/CrystalBridgeConverse.lean#L18)

- Resonance · A lower bound on the energy limsup at a simple critical-line zero. [simple_zero_energy_limsup_ge](projects/energy-extensions/R5SimpleZeroResonance.lean#L1581)

- Joint corollary · Applies the energy implication to the RH proof term imported from Alpöge’s Main. [joint_energy_bound](projects/energy-joint-433/JointCorollary.lean#L12)

- Joint Farey result · Uses the imported allChi to deduce twisted cancellation. [allChiVCancellation_holds](projects/farey-joint-433/Compose.lean#L22)

- Wilson · Inverse pairing on the polygon yields the factorial congruence. [wilson_from_polygon](projects/wilson-polygon/WilsonMechanism.lean#L164)

- Factorial oracle · The first drop identifies the least prime factor under the stated search hypotheses. [firstDrop_finds_minFac](projects/factorial-oracle/FactorSearch.lean#L100)

- Factorial blocks · The first noncoprime entry in the first hit block gives the least factor. [first_noncoprime_in_first_hit_block_eq_minFac](projects/pollard-strassen/PollardStrassenNTT.lean#L476)

- Möbius lift · Root multiplicity for the worked 720 diagonal. [diagonalLift_720_rootMultiplicity](projects/mobius-lift-diagonal/MobiusLiftDiagonal.lean#L73)

- Phase address · Products of successive dyadic phasors converge to the addressed phase. [dyadic_phase_products_tendsto](theorems/FVLTPhaseAddressV1.lean#L182)

- Centered comb · Alignment of the teeth is equivalent to the meridian condition. [align_iff_meridian](theorems/FVLTCenteredCombLemmaV1.lean#L426)

- Joint Fourier node · The pen supplies the finite character-transform identities used in the variant proof. [hat_char_props](projects/pen-gauss-joint-433/VariantDirichletProps.lean#L74)

## External dependencies

The frozen FVLT library uses the following upstream sources. The separate joint ports also import declarations from Alpöge’s Lean 4.33.1 environment.

- [Alpöge · Main imported by the joint composition (archived revision)](https://github.com/homeowmorphism/riemann-hypothesis-original/blob/40e56bab026552e089d7afcfeff08d2defb9c005/src/Main.lean)

- [Mathlib · Lean 4.35.0 library pin](https://github.com/leanprover-community/mathlib4/tree/56a005855ea17e0b0958f73ec801ae140b0a1679)

- [Mathlib · Lean 4.33.1 joint port](https://github.com/leanprover-community/mathlib4/tree/0df444a3)

- [Ruliology.CellularAutomata.Rule30Prize](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Prize.lean)

- [Ruliology.CellularAutomata.Rule30Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Jen.lean)

- [Ruliology.CellularAutomata.Rule30ZeroBoundaryBarriers](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30ZeroBoundaryBarriers.lean)

- [Ruliology.CellularAutomata.Rule30Realization](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Realization.lean)

- [Ruliology.CellularAutomata.Rule30ZeroBoundary](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30ZeroBoundary.lean)

- [Ruliology.CellularAutomata.Rule30PeriodTwo](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30PeriodTwo.lean)

- [Ruliology.CellularAutomata.Rule30DrivenLeft](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30DrivenLeft.lean)

- [Ruliology.CellularAutomata.Rule30MaskedJen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30MaskedJen.lean)

- [Ruliology.CellularAutomata.Rule30BlackRuns](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30BlackRuns.lean)

- [Ruliology.CellularAutomata.Rule30Diagonals](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Diagonals.lean)

- [Ruliology.CellularAutomata.Rule30FiniteConfigs](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30FiniteConfigs.lean)

- [Ruliology.CellularAutomata.Rule30PeriodTwoSideways](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30PeriodTwoSideways.lean)

- [Ruliology.CellularAutomata.Rule30PeriodTwoCoupled](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30PeriodTwoCoupled.lean)

- [Ruliology.CellularAutomata.Rule30Ether](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Ether.lean)

- [Ruliology.CellularAutomata.Rule30StripCertificates](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30StripCertificates.lean)

- [Ruliology.CellularAutomata.Rule30GateTrap](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30GateTrap.lean)

- [Ruliology.CellularAutomata.Rule30SpacingRenormalization](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30SpacingRenormalization.lean)

- [Ruliology.CellularAutomata.Rule30DrivenPrefix](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30DrivenPrefix.lean)

- [Ruliology.CellularAutomata.Rule30Certificates.GateTrap](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean)

## All Lean files

The links below use paths relative to this checkout. The public index links to a fixed Git commit.

### FVLT theorem library and its local imports (130)

- [Lean/theorems/FVLTActualSpinSpectrumV1.lean](theorems/FVLTActualSpinSpectrumV1.lean#L15) · theorem actual_cyclic_spin_update

- [Lean/theorems/FVLTAlphaAmplitudeV1.lean](theorems/FVLTAlphaAmplitudeV1.lean#L31) · theorem radial_power_pos

- [Lean/theorems/FVLTAtomSkinCountsV1.lean](theorems/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [Lean/theorems/FVLTAtomSkinDataV1.lean](theorems/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [Lean/theorems/FVLTAtomSkinPenV1.lean](theorems/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [Lean/theorems/FVLTBeatPeriodV1.lean](theorems/FVLTBeatPeriodV1.lean#L14) · theorem addOrderOf_intCast

- [Lean/theorems/FVLTCenteredCombLemmaV1.lean](theorems/FVLTCenteredCombLemmaV1.lean#L35) · theorem helper_phase_cos_sin

- [Lean/theorems/FVLTCliffordGeometryV1.lean](theorems/FVLTCliffordGeometryV1.lean#L17) · theorem clock_norm

- [Lean/theorems/FVLTConductorProjectorsV1.lean](theorems/FVLTConductorProjectorsV1.lean#L65) · theorem moebius_sum_divisors_eq

- [Lean/theorems/FVLTConeSectorV1.lean](theorems/FVLTConeSectorV1.lean#L20) · theorem cone_radial

- [Lean/theorems/FVLTConeSpiralV1.lean](theorems/FVLTConeSpiralV1.lean#L17) · theorem spiral_radius

- [Lean/theorems/FVLTCoupledPointV1.lean](theorems/FVLTCoupledPointV1.lean#L33) · theorem n3_real_pos

- [Lean/theorems/FVLTCyclicShiftWitnessV1.lean](theorems/FVLTCyclicShiftWitnessV1.lean#L15) · theorem plusDFT_shift

- [Lean/theorems/FVLTDiceExactV1.lean](theorems/FVLTDiceExactV1.lean#L47) · theorem limit_eq

- [Lean/theorems/FVLTDivisorBoltzmannV1.lean](theorems/FVLTDivisorBoltzmannV1.lean#L50) · theorem prime_index_prime

- [Lean/theorems/FVLTFareyArithmeticCompletionV1.lean](theorems/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [Lean/theorems/FVLTFareyCertificatesV1.lean](theorems/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [Lean/theorems/FVLTFareyContactV1.lean](theorems/FVLTFareyContactV1.lean#L12) · def det

- [Lean/theorems/FVLTFareyFixturesCompletionV1.lean](theorems/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [Lean/theorems/FVLTFiniteStateObstructionV1.lean](theorems/FVLTFiniteStateObstructionV1.lean#L15) · theorem equal_future_of_equal

- [Lean/theorems/FVLTFordBulbCombinatoricsV1.lean](theorems/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [Lean/theorems/FVLTFordBulbDataV1.lean](theorems/FVLTFordBulbDataV1.lean#L19) · def address

- [Lean/theorems/FVLTFordBulbGapLadderV1.lean](theorems/FVLTFordBulbGapLadderV1.lean#L35) · theorem word_mem

- [Lean/theorems/FVLTFordBulbMediantWordV1.lean](theorems/FVLTFordBulbMediantWordV1.lean#L27) · theorem raw_digit_carry0

- [Lean/theorems/FVLTFordBulbParameterV1.lean](theorems/FVLTFordBulbParameterV1.lean#L6) · theorem parameter_fixed_point

- [Lean/theorems/FVLTFordBulbUniquenessV1.lean](theorems/FVLTFordBulbUniquenessV1.lean#L46) · theorem setRank_orbitSet

- [Lean/theorems/FVLTFordExactCoordinatesV1.lean](theorems/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [Lean/theorems/FVLTFordGeometryCompletionV1.lean](theorems/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [Lean/theorems/FVLTFordGeometryV1.lean](theorems/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [Lean/theorems/FVLTFordRationalV1.lean](theorems/FVLTFordRationalV1.lean#L7) · def radiusQ

- [Lean/theorems/FVLTGearboxV1.lean](theorems/FVLTGearboxV1.lean#L18) · theorem k1_step

- [Lean/theorems/FVLTGolayWalkHolonomyV1.lean](theorems/FVLTGolayWalkHolonomyV1.lean#L83) · theorem chain_nil

- [Lean/theorems/FVLTHelixFrameV1.lean](theorems/FVLTHelixFrameV1.lean#L10) · theorem phase_zero

- [Lean/theorems/FVLTHelixGearboxV1.lean](theorems/FVLTHelixGearboxV1.lean#L23) · theorem advance_zero

- [Lean/theorems/FVLTHopfClockBridgeV1.lean](theorems/FVLTHopfClockBridgeV1.lean#L17) · theorem realise_injective

- [Lean/theorems/FVLTMCombHelixV1.lean](theorems/FVLTMCombHelixV1.lean#L15) · theorem offset_injective

- [Lean/theorems/FVLTN6MirrorV1.lean](theorems/FVLTN6MirrorV1.lean#L16) · theorem mirror_twice

- [Lean/theorems/FVLTN6OrientationV1.lean](theorems/FVLTN6OrientationV1.lean#L18) · theorem point_zero

- [Lean/theorems/FVLTN6YReflectionV1.lean](theorems/FVLTN6YReflectionV1.lean#L14) · theorem point_zero

- [Lean/theorems/FVLTNaturalFanV1.lean](theorems/FVLTNaturalFanV1.lean#L21) · theorem period_pos

- [Lean/theorems/FVLTNonlinearSpectralV1.lean](theorems/FVLTNonlinearSpectralV1.lean#L21) · theorem doubled_polyUpdate

- [Lean/theorems/FVLTNoWrapPaddingV1.lean](theorems/FVLTNoWrapPaddingV1.lean#L13) · theorem padding_pos

- [Lean/theorems/FVLTPeriodProjectorsV1.lean](theorems/FVLTPeriodProjectorsV1.lean#L178) · theorem Q_eq_resSum

- [Lean/theorems/FVLTPhaseAddressV1.lean](theorems/FVLTPhaseAddressV1.lean#L21) · theorem phasor_zero

- [Lean/theorems/FVLTPhasePartnersV1.lean](theorems/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [Lean/theorems/FVLTPillowcaseDataV1.lean](theorems/FVLTPillowcaseDataV1.lean#L15) · def translation

- [Lean/theorems/FVLTPillowcaseV1.lean](theorems/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [Lean/theorems/FVLTProductConvolutionV1.lean](theorems/FVLTProductConvolutionV1.lean#L18) · theorem convolution_transforms

- [Lean/theorems/FVLTRingSemanticsV1.lean](theorems/FVLTRingSemanticsV1.lean#L11) · theorem ring_read

- [Lean/theorems/FVLTRosetteEntropyV1.lean](theorems/FVLTRosetteEntropyV1.lean#L29) · theorem uniform_mass_sum

- [Lean/theorems/FVLTRosetteFairBridgeV1.lean](theorems/FVLTRosetteFairBridgeV1.lean#L24) · theorem spiral_mass_sum

- [Lean/theorems/FVLTRosetteFordArithmeticV1.lean](theorems/FVLTRosetteFordArithmeticV1.lean#L6) · theorem integer_address_iff

- [Lean/theorems/FVLTRosetteFordDataV1.lean](theorems/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [Lean/theorems/FVLTRosetteFordEndpointsV1.lean](theorems/FVLTRosetteFordEndpointsV1.lean#L6) · theorem det_zero_iff_address_equal

- [Lean/theorems/FVLTRosetteFordPhaseV1.lean](theorems/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [Lean/theorems/FVLTRosetteFordSweepV1.lean](theorems/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [Lean/theorems/FVLTRosetteLogLossV1.lean](theorems/FVLTRosetteLogLossV1.lean#L15) · theorem crossEntropy_sub_entropy_eq_finiteKL

- [Lean/theorems/FVLTRosetteTrailV1.lean](theorems/FVLTRosetteTrailV1.lean#L23) · theorem cap_pos

- [Lean/theorems/FVLTRule30FiniteCertificateV1.lean](theorems/FVLTRule30FiniteCertificateV1.lean#L17) · theorem checkExtinct_eq_true_iff

- [Lean/theorems/FVLTRule30FiniteReconstructionV1.lean](theorems/FVLTRule30FiniteReconstructionV1.lean#L30) · theorem trace_one

- [Lean/theorems/FVLTRule30GateReturnFrequencyLimitsV1.lean](theorems/FVLTRule30GateReturnFrequencyLimitsV1.lean#L12) · theorem returns_strictMono

- [Lean/theorems/FVLTRule30GateReturnFrequencyV1.lean](theorems/FVLTRule30GateReturnFrequencyV1.lean#L10) · theorem successive_returns_exists_unique

- [Lean/theorems/FVLTRule30GateTrapWords33CertV1.lean](theorems/FVLTRule30GateTrapWords33CertV1.lean#L108) · theorem check33_00

- [Lean/theorems/FVLTRule30GateTrapWords3553CertV1.lean](theorems/FVLTRule30GateTrapWords3553CertV1.lean#L139) · theorem check3553_00

- [Lean/theorems/FVLTRule30GateTrapWordsV1.lean](theorems/FVLTRule30GateTrapWordsV1.lean#L18) · theorem mem_mask_true

- [Lean/theorems/FVLTRule30K2DepthCollisionV1.lean](theorems/FVLTRule30K2DepthCollisionV1.lean#L15) · theorem k2_black_first_same_mask_depth_different_next

- [Lean/theorems/FVLTRule30K2LiftedClosureWitnessV1.lean](theorems/FVLTRule30K2LiftedClosureWitnessV1.lean#L16) · theorem k2_black_first_equal_lift_different_next_baseline

- [Lean/theorems/FVLTRule30LeftTemporalEnergyV1.lean](theorems/FVLTRule30LeftTemporalEnergyV1.lean#L34) · theorem xor_true_ne

- [Lean/theorems/FVLTRule30LiftedBaselineV1.lean](theorems/FVLTRule30LiftedBaselineV1.lean#L24) · theorem trace_one

- [Lean/theorems/FVLTRule30LiftedDepthFeedbackV1.lean](theorems/FVLTRule30LiftedDepthFeedbackV1.lean#L11) · theorem trace_next

- [Lean/theorems/FVLTRule30PeriodicSeedControlV1.lean](theorems/FVLTRule30PeriodicSeedControlV1.lean#L27) · theorem evol_mod4

- [Lean/theorems/FVLTRule30PsiSupportBridgeV1.lean](theorems/FVLTRule30PsiSupportBridgeV1.lean#L14) · theorem actual_traceColumn_positive

- [Lean/theorems/FVLTRule30RightStripV1.lean](theorems/FVLTRule30RightStripV1.lean#L72) · theorem fold_count

- [Lean/theorems/FVLTRule30SecondLeftMismatchV1.lean](theorems/FVLTRule30SecondLeftMismatchV1.lean#L19) · theorem xor_true_ne

- [Lean/theorems/FVLTRule30SpinV1.lean](theorems/FVLTRule30SpinV1.lean#L15) · theorem spin_convention

- [Lean/theorems/FVLTRule30TemporalLeakEnergyV1.lean](theorems/FVLTRule30TemporalLeakEnergyV1.lean#L21) · theorem center_off_energy_zero

- [Lean/theorems/FVLTS4dScannerV1.lean](theorems/FVLTS4dScannerV1.lean#L19) · theorem scan_zero

- [Lean/theorems/FVLTS4dSpanReductionV1.lean](theorems/FVLTS4dSpanReductionV1.lean#L25) · theorem exists_rightmost

- [Lean/theorems/FVLTS4eUniformPeriodV1.lean](theorems/FVLTS4eUniformPeriodV1.lean#L28) · theorem period_pullback_at_threshold

- [Lean/theorems/FVLTS4fMaskedLeakV1.lean](theorems/FVLTS4fMaskedLeakV1.lean#L16) · theorem mask_equality_iff

- [Lean/theorems/FVLTS4fSpanTimeV1.lean](theorems/FVLTS4fSpanTimeV1.lean#L23) · theorem evolveSeed_zero_row

- [Lean/theorems/FVLTS4gForcedBitCountV1.lean](theorems/FVLTS4gForcedBitCountV1.lean#L38) · theorem completeOutput_blackPins

- [Lean/theorems/FVLTS4gLBEImplicationV1.lean](theorems/FVLTS4gLBEImplicationV1.lean#L34) · theorem finiteLeft_of_finConfig

- [Lean/theorems/FVLTS4gLeftScreenV1.lean](theorems/FVLTS4gLeftScreenV1.lean#L15) · theorem left_screen

- [Lean/theorems/FVLTS4hAlternatingZeroV1.lean](theorems/FVLTS4hAlternatingZeroV1.lean#L15) · theorem oddProfile_rule

- [Lean/theorems/FVLTS4hFiniteTailV1.lean](theorems/FVLTS4hFiniteTailV1.lean#L22) · theorem eventuallyZero_iff_projections

- [Lean/theorems/FVLTS4hInfinitePinsV1.lean](theorems/FVLTS4hInfinitePinsV1.lean#L19) · theorem prefixTrace_restrict

- [Lean/theorems/FVLTS4iResidualV1.lean](theorems/FVLTS4iResidualV1.lean#L44) · theorem eval_prepend

- [Lean/theorems/FVLTS4iUniformPaddingV1.lean](theorems/FVLTS4iUniformPaddingV1.lean#L27) · theorem zeroCompleted_pins_before

- [Lean/theorems/FVLTS4jBoundedDeathV1.lean](theorems/FVLTS4jBoundedDeathV1.lean#L41) · theorem completed_restrictWhite

- [Lean/theorems/FVLTS4kCollapseV1.lean](theorems/FVLTS4kCollapseV1.lean#L20) · theorem exactDeath_has_predecessor_survivor

- [Lean/theorems/FVLTS4kCoreV1.lean](theorems/FVLTS4kCoreV1.lean#L18) · theorem hasWidth_iff_depth

- [Lean/theorems/FVLTS4kDomReductionV1.lean](theorems/FVLTS4kDomReductionV1.lean#L28) · theorem dStar_deadBy

- [Lean/theorems/FVLTS4lZeroBoundaryV1.lean](theorems/FVLTS4lZeroBoundaryV1.lean#L31) · theorem singleBlack_isolated

- [Lean/theorems/FVLTS4mCoordinatesV1.lean](theorems/FVLTS4mCoordinatesV1.lean#L59) · theorem completion10_white

- [Lean/theorems/FVLTS4mMachineBridgeV1.lean](theorems/FVLTS4mMachineBridgeV1.lean#L19) · theorem prefixCons_samePrefix

- [Lean/theorems/FVLTS4mOddPhaseThetaV1.lean](theorems/FVLTS4mOddPhaseThetaV1.lean#L25) · theorem completion01_odd_samples

- [Lean/theorems/FVLTS4mResidualV1.lean](theorems/FVLTS4mResidualV1.lean#L69) · theorem prefixAppend_empty

- [Lean/theorems/FVLTS4nHarmonicTransportV1.lean](theorems/FVLTS4nHarmonicTransportV1.lean#L22) · theorem sampleIndex_lt

- [Lean/theorems/FVLTS4nPaddingWalkV1.lean](theorems/FVLTS4nPaddingWalkV1.lean#L14) · theorem inverseTwo_spec

- [Lean/theorems/FVLTS4nPrimeReadoutV1.lean](theorems/FVLTS4nPrimeReadoutV1.lean#L19) · theorem spin_square

- [Lean/theorems/FVLTS4nShellTransportV1.lean](theorems/FVLTS4nShellTransportV1.lean#L25) · theorem actual_weave_step

- [Lean/theorems/FVLTS4qGatePhaseV1.lean](theorems/FVLTS4qGatePhaseV1.lean#L10) · theorem phase_pi

- [Lean/theorems/FVLTS4qSpinGateV1.lean](theorems/FVLTS4qSpinGateV1.lean#L19) · theorem spin_false

- [Lean/theorems/FVLTS4sRule150PenV1.lean](theorems/FVLTS4sRule150PenV1.lean#L23) · theorem two_step

- [Lean/theorems/FVLTS4sSqueezeCornersV1.lean](theorems/FVLTS4sSqueezeCornersV1.lean#L27) · theorem cos_ang

- [Lean/theorems/FVLTStageAIntegrationV1.lean](theorems/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [Lean/theorems/FVLTTemporalMismatchEnergyV1.lean](theorems/FVLTTemporalMismatchEnergyV1.lean#L30) · theorem off_energy_two_block

- [Lean/theorems/FVLTTurnFourierPenV1.lean](theorems/FVLTTurnFourierPenV1.lean#L24) · theorem zeta_eq_exp

- [Lean/theorems/FVLTTurnFourierV1.lean](theorems/FVLTTurnFourierV1.lean#L17) · theorem plusDFT_apply

- [Lean/theorems/FVLTTwoClockV1.lean](theorems/FVLTTwoClockV1.lean#L21) · theorem clock_pos

- [Lean/theorems/FVLTUnitFractionSpineV1.lean](theorems/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [Lean/theorems/FVLTWalkTiltV1.lean](theorems/FVLTWalkTiltV1.lean#L21) · theorem weight_pos

- [Lean/theorems/FVLTWovenCanonicalV1.lean](theorems/FVLTWovenCanonicalV1.lean#L22) · theorem half_partition

- [Lean/theorems/FVLTWovenCertificateV1.lean](theorems/FVLTWovenCertificateV1.lean#L16) · theorem readPacked_rep

- [Lean/theorems/FVLTWovenCylinderV1.lean](theorems/FVLTWovenCylinderV1.lean#L17) · theorem fixed_ring_step

- [Lean/theorems/FVLTWovenEvolutionV1.lean](theorems/FVLTWovenEvolutionV1.lean#L21) · theorem infinite_left_false

- [Lean/theorems/FVLTWovenFiniteHorizonV1.lean](theorems/FVLTWovenFiniteHorizonV1.lean#L11) · theorem weave_eq_infinite_rep_up_to

- [Lean/theorems/FVLTWovenKitBridgeV1.lean](theorems/FVLTWovenKitBridgeV1.lean#L13) · theorem infinite_eq_kit

- [Lean/theorems/FVLTYReflectionV1.lean](theorems/FVLTYReflectionV1.lean#L15) · theorem reflect_re

- [Lean/theorems/Ruliology/CellularAutomata/Rule30LeftConductorTransferV1.lean](theorems/Ruliology/CellularAutomata/Rule30LeftConductorTransferV1.lean#L76) · theorem leftSidewaysBit_iff_rule30Bit

- [Lean/theorems/S4g.lean](theorems/S4g.lean#L5) · #print axioms

- [Lean/theorems/S4h.lean](theorems/S4h.lean#L5) · #print axioms

- [Lean/theorems/S4h_G_CantorShiftV1.lean](theorems/S4h_G_CantorShiftV1.lean#L24) · theorem cantorBody_black_seed_forced

- [Lean/theorems/S4i_G_UniformLatchV1.lean](theorems/S4i_G_UniformLatchV1.lean#L19) · theorem s_neg_two_of_c0_false

- [Lean/theorems/S4j_G_UniformCascadeV1.lean](theorems/S4j_G_UniformCascadeV1.lean#L53) · theorem or_neg_self

- [Lean/theorems/S4k_G_DecreasingMeasureV1.lean](theorems/S4k_G_DecreasingMeasureV1.lean#L70) · theorem survivesPinsUpTo_mono

- [Lean/theorems/S4l_G_ZeroBoundaryPotentialsV1.lean](theorems/S4l_G_ZeroBoundaryPotentialsV1.lean#L79) · theorem stepSeed_eq_zero_of_pin

- [Lean/theorems/S4m_G_PeriodTwoResidualsV1.lean](theorems/S4m_G_PeriodTwoResidualsV1.lean#L80) · theorem residualEquiv_refl

- [Lean/theorems/S4n_G_PeriodTwoTargetIV1.lean](theorems/S4n_G_PeriodTwoTargetIV1.lean#L99) · theorem xor_self_right

### arithmetic-fourier-rh (5)

- [Lean/projects/arithmetic-fourier-rh/CoherentEnergyMeasure.lean](projects/arithmetic-fourier-rh/CoherentEnergyMeasure.lean#L20) · theorem poissonKernel_denom_pos

- [Lean/projects/arithmetic-fourier-rh/CoherentEnergyRHBridge.lean](projects/arithmetic-fourier-rh/CoherentEnergyRHBridge.lean#L9) · theorem mertens_eq_M

- [Lean/projects/arithmetic-fourier-rh/StatementPins.lean](projects/arithmetic-fourier-rh/StatementPins.lean#L71) · theorem nu_eq

- [Lean/projects/arithmetic-fourier-rh/verification/checker/IndependentFVLTReplay436.lean](projects/arithmetic-fourier-rh/verification/checker/IndependentFVLTReplay436.lean#L18) · def allowedAxioms

- [Lean/projects/arithmetic-fourier-rh/Verified.lean](projects/arithmetic-fourier-rh/Verified.lean#L128) · theorem allOnes_sq

### arithmetic-fourier-rh · fragments (335)

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualBlockEndpointEnergy.lean](projects/arithmetic-fourier-rh/fragments/ActualBlockEndpointEnergy.lean#L10) · theorem rank_pair_energy_of_buthe_endpoints

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualBlockEnergySmoothing.lean](projects/arithmetic-fourier-rh/fragments/ActualBlockEnergySmoothing.lean#L12) · theorem sum_of_sign_position_counts

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualDerivatives.lean](projects/arithmetic-fourier-rh/fragments/ActualDerivatives.lean#L15) · theorem smoothDelayed_derivatives

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualLongRankCenter.lean](projects/arithmetic-fourier-rh/fragments/ActualLongRankCenter.lean#L9) · theorem long_row_entry_linear_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualLongRankModel.lean](projects/arithmetic-fourier-rh/fragments/ActualLongRankModel.lean#L42) · theorem right_height_finite

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualNormalizedRankWindow.lean](projects/arithmetic-fourier-rh/fragments/ActualNormalizedRankWindow.lean#L13) · theorem actual_normalized_window

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualRestrictedZetaTrace.lean](projects/arithmetic-fourier-rh/fragments/ActualRestrictedZetaTrace.lean#L13) · theorem riemannHypothesis_of_zeta_restricted_traces

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualRightInverseHeight.lean](projects/arithmetic-fourier-rh/fragments/ActualRightInverseHeight.lean#L12) · theorem right_zero_nonzero_ordinate

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualSampledRankWindow.lean](projects/arithmetic-fourier-rh/fragments/ActualSampledRankWindow.lean#L18) · theorem actual_sampled_rank_window_inequality

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualTargetZeroSet.lean](projects/arithmetic-fourier-rh/fragments/ActualTargetZeroSet.lean#L12) · theorem right_value_injective

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualWeightedRightDensity.lean](projects/arithmetic-fourier-rh/fragments/ActualWeightedRightDensity.lean#L11) · theorem weighted_right_finset

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualWindowLongRankBound.lean](projects/arithmetic-fourier-rh/fragments/ActualWindowLongRankBound.lean#L17) · theorem actual_frozen_rank_window_inequality

- [Lean/projects/arithmetic-fourier-rh/fragments/ActualZetaZeroCount.lean](projects/arithmetic-fourier-rh/fragments/ActualZetaZeroCount.lean#L6) · theorem entireXi_jensen_growth

- [Lean/projects/arithmetic-fourier-rh/fragments/AffineFromRealPart.lean](projects/arithmetic-fourier-rh/fragments/AffineFromRealPart.lean#L14) · theorem halfDisc

- [Lean/projects/arithmetic-fourier-rh/fragments/AnalyticObligations.lean](projects/arithmetic-fourier-rh/fragments/AnalyticObligations.lean#L15) · def halfPlane

- [Lean/projects/arithmetic-fourier-rh/fragments/AnalyticZeroResidue.lean](projects/arithmetic-fourier-rh/fragments/AnalyticZeroResidue.lean#L9) · theorem analyticOrder_logDerivative_residue

- [Lean/projects/arithmetic-fourier-rh/fragments/AnalyticZeroSum.lean](projects/arithmetic-fourier-rh/fragments/AnalyticZeroSum.lean#L9) · theorem zero_order_positive

- [Lean/projects/arithmetic-fourier-rh/fragments/AngularDecay.lean](projects/arithmetic-fourier-rh/fragments/AngularDecay.lean#L9) · theorem uniform_angular_quadratic_decay

- [Lean/projects/arithmetic-fourier-rh/fragments/ArchimedeanCutoff.lean](projects/arithmetic-fourier-rh/fragments/ArchimedeanCutoff.lean#L17) · theorem pointwise_lower_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ArchimedeanLimit.lean](projects/arithmetic-fourier-rh/fragments/ArchimedeanLimit.lean#L9) · theorem logTest_linear

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierComplementBound.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierComplementBound.lean#L22) · theorem sum_increasing_pairs

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDenseTests.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDenseTests.lean#L12) · theorem sqNorm_nonneg

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicAbel.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicAbel.lean#L9) · theorem block_abel_identity

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicBandwidth.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicBandwidth.lean#L9) · theorem quotient_cutoff_spacing

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicConvolution.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicConvolution.lean#L11) · theorem aggregate_convolution

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicKernel.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicKernel.lean#L13) · theorem aggregate_eq_mobius_kernel

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicOrthogonal.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierDyadicOrthogonal.lean#L8) · theorem separated_cutoff_residual_cost

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierFullCorrelation.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierFullCorrelation.lean#L11) · theorem logDeriv_mul

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierGrowth.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierGrowth.lean#L10) · theorem abs_g_le

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierIncrement.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierIncrement.lean#L10) · theorem muR_apply_cast

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierInversion.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierInversion.lean#L13) · theorem g_apply

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPairBlock.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPairBlock.lean#L14) · theorem paired_seed_iff

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierParityInverse.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierParityInverse.lean#L10) · theorem floor_even_split

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPrimeMatching.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPrimeMatching.lean#L8) · theorem shell_primes_eq_half_shell

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPrimePartners.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierPrimePartners.lean#L10) · theorem prime_cofactor_properties

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankBandwidth.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankBandwidth.lean#L12) · theorem index_band_card

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankCost.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankCost.lean#L9) · theorem average_add

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankGram.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankGram.lean#L11) · theorem actual_residual_add

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankRestricted.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierRankRestricted.lean#L10) · theorem dyadic_block_discrepancy_l1

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShell.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShell.lean#L28) · theorem upper_odd_shell_iff

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShellGrowth.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShellGrowth.lean#L13) · theorem shell_log_mul_le

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShellMertens.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShellMertens.lean#L10) · theorem upper_odd_shell_eq_sdiff

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortEstimate.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortEstimate.lean#L8) · theorem centered_finite_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortMass.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortMass.lean#L11) · theorem short_weight_mass

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortPower.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortPower.lean#L8) · theorem sqrt_nat_le_real

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortSelection.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierShortSelection.lean#L9) · theorem block_discrepancy_eq_remainder

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierTouchedCost.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierTouchedCost.lean#L8) · theorem touched_mu_abs_le_one

- [Lean/projects/arithmetic-fourier-rh/fragments/ArithmeticFourierWeakOscillation.lean](projects/arithmetic-fourier-rh/fragments/ArithmeticFourierWeakOscillation.lean#L11) · theorem stride_monotone

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraLocalModeContrast.lean](projects/arithmetic-fourier-rh/fragments/AstraLocalModeContrast.lean#L16) · theorem segment_mem

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraPrimeRightCut.lean](projects/arithmetic-fourier-rh/fragments/AstraPrimeRightCut.lean#L21) · theorem zero_sum_minus_right

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraPrimeRightEndpoint.lean](projects/arithmetic-fourier-rh/fragments/AstraPrimeRightEndpoint.lean#L8) · theorem chebyshev_endpoint_reduction

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraPrimeRightFinite.lean](projects/arithmetic-fourier-rh/fragments/AstraPrimeRightFinite.lean#L8) · theorem rightSet_finite

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraRampVariation.lean](projects/arithmetic-fourier-rh/fragments/AstraRampVariation.lean#L8) · theorem shell_variation

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraSharpDyadicX.lean](projects/arithmetic-fourier-rh/fragments/AstraSharpDyadicX.lean#L6) · theorem sharp_dyadic_X

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraSharpIndividual.lean](projects/arithmetic-fourier-rh/fragments/AstraSharpIndividual.lean#L8) · theorem sharp_individual_endpoint

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraSharpRadialTail.lean](projects/arithmetic-fourier-rh/fragments/AstraSharpRadialTail.lean#L9) · theorem annulus_count

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraSharpRightEndpoint.lean](projects/arithmetic-fourier-rh/fragments/AstraSharpRightEndpoint.lean#L14) · theorem at_width

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraSharpZeroRemainder.lean](projects/arithmetic-fourier-rh/fragments/AstraSharpZeroRemainder.lean#L10) · theorem sharpened_zero_remainder

- [Lean/projects/arithmetic-fourier-rh/fragments/AstraUnitRotatedContrast.lean](projects/arithmetic-fourier-rh/fragments/AstraUnitRotatedContrast.lean#L10) · theorem unitRotation_norm

- [Lean/projects/arithmetic-fourier-rh/fragments/AsymptoticTraceCriterion.lean](projects/arithmetic-fourier-rh/fragments/AsymptoticTraceCriterion.lean#L13) · theorem compensated_limit_from_residual

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockComplexTransfer.lean](projects/arithmetic-fourier-rh/fragments/BlockComplexTransfer.lean#L14) · theorem complex_interval_smoothing_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockCutoffIntervals.lean](projects/arithmetic-fourier-rh/fragments/BlockCutoffIntervals.lean#L13) · theorem block_active_filter_eq_range

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockDirichletBound.lean](projects/arithmetic-fourier-rh/fragments/BlockDirichletBound.lean#L7) · theorem norm_exp_double_angle_sub_one

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockDirichletMoments.lean](projects/arithmetic-fourier-rh/fragments/BlockDirichletMoments.lean#L8) · theorem block_char_sum

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockEndpointBounds.lean](projects/arithmetic-fourier-rh/fragments/BlockEndpointBounds.lean#L9) · theorem cyclic_interval_endpoint_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockFlatTop.lean](projects/arithmetic-fourier-rh/fragments/BlockFlatTop.lean#L16) · theorem mem_flatMask

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockIntervalEnergy.lean](projects/arithmetic-fourier-rh/fragments/BlockIntervalEnergy.lean#L18) · theorem interval_vector_norm

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockIntervalShift.lean](projects/arithmetic-fourier-rh/fragments/BlockIntervalShift.lean#L10) · theorem block_interval_one_shift

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockIntervalVariance.lean](projects/arithmetic-fourier-rh/fragments/BlockIntervalVariance.lean#L10) · theorem interval_energy_variance

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockJacksonMoment.lean](projects/arithmetic-fourier-rh/fragments/BlockJacksonMoment.lean#L9) · theorem jackson_circular_first_moment

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockJacksonSpectrum.lean](projects/arithmetic-fourier-rh/fragments/BlockJacksonSpectrum.lean#L12) · theorem tone_add

- [Lean/projects/arithmetic-fourier-rh/fragments/BlockWeightedVariance.lean](projects/arithmetic-fourier-rh/fragments/BlockWeightedVariance.lean#L7) · theorem weighted_variance_split

- [Lean/projects/arithmetic-fourier-rh/fragments/BoundedComplexCenter.lean](projects/arithmetic-fourier-rh/fragments/BoundedComplexCenter.lean#L6) · theorem bounded_complex_center

- [Lean/projects/arithmetic-fourier-rh/fragments/CandidateFourierBounds.lean](projects/arithmetic-fourier-rh/fragments/CandidateFourierBounds.lean#L7) · theorem fullCandidate_uniform_angular_decay

- [Lean/projects/arithmetic-fourier-rh/fragments/CanonicalFactor.lean](projects/arithmetic-fourier-rh/fragments/CanonicalFactor.lean#L9) · theorem genusOne_differentiable

- [Lean/projects/arithmetic-fourier-rh/fragments/CanonicalProductGrowth.lean](projects/arithmetic-fourier-rh/fragments/CanonicalProductGrowth.lean#L8) · theorem norm_genusOne_le_exp_three_halves

- [Lean/projects/arithmetic-fourier-rh/fragments/CenteredDistanceTransfer.lean](projects/arithmetic-fourier-rh/fragments/CenteredDistanceTransfer.lean#L11) · theorem norm_weighted_row

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevConverse.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevConverse.lean#L8) · theorem mangoldt_integrand_integrable

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevDesmoothing.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevDesmoothing.lean#L7) · theorem chebyshev_cancellation_of_smoothed_power

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevDyadicPower.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevDyadicPower.lean#L13) · theorem chebyshev_trivial_error

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevFixedPowerConverse.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevFixedPowerConverse.lean#L15) · theorem power_cut_chebyshev_local

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevLogDerivativeGrowth.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevLogDerivativeGrowth.lean#L10) · theorem regularizedLogDerivative_outer_log

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevRampApproximation.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevRampApproximation.lean#L14) · theorem smoothedChebyshev_error

- [Lean/projects/arithmetic-fourier-rh/fragments/ChebyshevToResidual.lean](projects/arithmetic-fourier-rh/fragments/ChebyshevToResidual.lean#L24) · theorem cut_local

- [Lean/projects/arithmetic-fourier-rh/fragments/CofinalTraceCriterion.lean](projects/arithmetic-fourier-rh/fragments/CofinalTraceCriterion.lean#L5) · theorem riemannHypothesis_of_cofinal_restricted_finite_traces

- [Lean/projects/arithmetic-fourier-rh/fragments/CoherentEnergyBounds.lean](projects/arithmetic-fourier-rh/fragments/CoherentEnergyBounds.lean#L10) · theorem factor_nonneg

- [Lean/projects/arithmetic-fourier-rh/fragments/CoherentEnergyTraceBridge.lean](projects/arithmetic-fourier-rh/fragments/CoherentEnergyTraceBridge.lean#L7) · theorem mertens_eq_natural_M

- [Lean/projects/arithmetic-fourier-rh/fragments/CompactApproximation.lean](projects/arithmetic-fourier-rh/fragments/CompactApproximation.lean#L18) · theorem fullCandidate_smooth

- [Lean/projects/arithmetic-fourier-rh/fragments/CompactDerivativeBounds.lean](projects/arithmetic-fourier-rh/fragments/CompactDerivativeBounds.lean#L6) · theorem fullCandidate_compact_derivative_bounds

- [Lean/projects/arithmetic-fourier-rh/fragments/CompactParameters.lean](projects/arithmetic-fourier-rh/fragments/CompactParameters.lean#L6) · theorem compact_parameter_gap

- [Lean/projects/arithmetic-fourier-rh/fragments/CompactPrimeSandwichTests.lean](projects/arithmetic-fourier-rh/fragments/CompactPrimeSandwichTests.lean#L14) · theorem interval_bump_one

- [Lean/projects/arithmetic-fourier-rh/fragments/CompactSpectralSummability.lean](projects/arithmetic-fourier-rh/fragments/CompactSpectralSummability.lean#L12) · theorem compact_zero_terms_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/CompensatedEulerSpectral.lean](projects/arithmetic-fourier-rh/fragments/CompensatedEulerSpectral.lean#L6) · theorem compensated_zeta_euler_spectral_limit_of_hadamard

- [Lean/projects/arithmetic-fourier-rh/fragments/CompensatedGeometryUnbounded.lean](projects/arithmetic-fourier-rh/fragments/CompensatedGeometryUnbounded.lean#L15) · theorem compensatedDensity_continuous

- [Lean/projects/arithmetic-fourier-rh/fragments/CompensatedZetaLimit.lean](projects/arithmetic-fourier-rh/fragments/CompensatedZetaLimit.lean#L30) · theorem compensated_zeta_limit_euler

- [Lean/projects/arithmetic-fourier-rh/fragments/CompletedZetaGrowth.lean](projects/arithmetic-fourier-rh/fragments/CompletedZetaGrowth.lean#L8) · theorem thetaTail_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/ComplexCyclicPotential.lean](projects/arithmetic-fourier-rh/fragments/ComplexCyclicPotential.lean#L8) · theorem complex_cyclic_potential_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ConcreteApproximation.lean](projects/arithmetic-fourier-rh/fragments/ConcreteApproximation.lean#L31) · theorem concreteApproximation_test

- [Lean/projects/arithmetic-fourier-rh/fragments/ContinuumModeExpansion.lean](projects/arithmetic-fourier-rh/fragments/ContinuumModeExpansion.lean#L12) · theorem mean_mul_const

- [Lean/projects/arithmetic-fourier-rh/fragments/ConvolutionTransfer.lean](projects/arithmetic-fourier-rh/fragments/ConvolutionTransfer.lean#L15) · theorem truncate

- [Lean/projects/arithmetic-fourier-rh/fragments/CountScale.lean](projects/arithmetic-fourier-rh/fragments/CountScale.lean#L6) · theorem cumulative_count_dyadic

- [Lean/projects/arithmetic-fourier-rh/fragments/CutoffProductBounds.lean](projects/arithmetic-fourier-rh/fragments/CutoffProductBounds.lean#L13) · theorem fullCandidate_leibniz_mass

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletConjugation.lean](projects/arithmetic-fourier-rh/fragments/DirichletConjugation.lean#L12) · theorem LFunction_conj_euler

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletEulerSpectral.lean](projects/arithmetic-fourier-rh/fragments/DirichletEulerSpectral.lean#L17) · theorem normalized_dirichlet_logDeriv_euler

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/DirichletFourierPairing.lean#L14) · theorem prime_shift_term

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletFullCriterion.lean](projects/arithmetic-fourier-rh/fragments/DirichletFullCriterion.lean#L10) · theorem dirichlet_fixed_strip_residual_iff

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletFullFiniteFormula.lean](projects/arithmetic-fourier-rh/fragments/DirichletFullFiniteFormula.lean#L12) · theorem dirichlet_zero_square_summable

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletGammaRelative.lean](projects/arithmetic-fourier-rh/fragments/DirichletGammaRelative.lean#L13) · theorem parityRealPlaceRelative_even

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletGeometricLimit.lean](projects/arithmetic-fourier-rh/fragments/DirichletGeometricLimit.lean#L15) · theorem halfWeight_zero_of_nonunit

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletHadamard.lean](projects/arithmetic-fourier-rh/fragments/DirichletHadamard.lean#L13) · theorem completed_dirichlet_zero_value_nonzero

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletImprimitiveFiniteFormula.lean](projects/arithmetic-fourier-rh/fragments/DirichletImprimitiveFiniteFormula.lean#L11) · theorem compact_prime_sum_summable

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletPrimitiveReduction.lean](projects/arithmetic-fourier-rh/fragments/DirichletPrimitiveReduction.lean#L14) · theorem removed_euler_factor_nonzero

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletResidualForward.lean](projects/arithmetic-fourier-rh/fragments/DirichletResidualForward.lean#L10) · theorem dirichlet_residual_zero_of_containment

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletRestrictedResidual.lean](projects/arithmetic-fourier-rh/fragments/DirichletRestrictedResidual.lean#L23) · theorem parityRelative_analyticAt

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletZeroCount.lean](projects/arithmetic-fourier-rh/fragments/DirichletZeroCount.lean#L8) · theorem completed_dirichlet_envelope

- [Lean/projects/arithmetic-fourier-rh/fragments/DirichletZeroSet.lean](projects/arithmetic-fourier-rh/fragments/DirichletZeroSet.lean#L14) · theorem gammaFactor_analytic_nonzero_pos

- [Lean/projects/arithmetic-fourier-rh/fragments/DiskNormInterpolation.lean](projects/arithmetic-fourier-rh/fragments/DiskNormInterpolation.lean#L8) · theorem norm_le_three_circle

- [Lean/projects/arithmetic-fourier-rh/fragments/DyadicEndpointPower.lean](projects/arithmetic-fourier-rh/fragments/DyadicEndpointPower.lean#L7) · theorem power_from_doubling_difference

- [Lean/projects/arithmetic-fourier-rh/fragments/EndpointIBP.lean](projects/arithmetic-fourier-rh/fragments/EndpointIBP.lean#L14) · theorem transfer_derivative

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireCanonicalProduct.lean](projects/arithmetic-fourier-rh/fragments/EntireCanonicalProduct.lean#L28) · theorem zero_norm_lower

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireGrowthEnvelope.lean](projects/arithmetic-fourier-rh/fragments/EntireGrowthEnvelope.lean#L12) · theorem const

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireHadamard.lean](projects/arithmetic-fourier-rh/fragments/EntireHadamard.lean#L8) · theorem product_norm_le_exp_three_halves

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireProductLogDerivative.lean](projects/arithmetic-fourier-rh/fragments/EntireProductLogDerivative.lean#L10) · theorem factor_logDerivative

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireQuotient.lean](projects/arithmetic-fourier-rh/fragments/EntireQuotient.lean#L14) · theorem quotient_meromorphic

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireXiGrowth.lean](projects/arithmetic-fourier-rh/fragments/EntireXiGrowth.lean#L8) · theorem entireXi_posLog_growth

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireXiOrders.lean](projects/arithmetic-fourier-rh/fragments/EntireXiOrders.lean#L9) · theorem entireXi_analytic

- [Lean/projects/arithmetic-fourier-rh/fragments/EntireXiZeroSet.lean](projects/arithmetic-fourier-rh/fragments/EntireXiZeroSet.lean#L5) · theorem entireXi_reflection

- [Lean/projects/arithmetic-fourier-rh/fragments/EulerGeometricLimit.lean](projects/arithmetic-fourier-rh/fragments/EulerGeometricLimit.lean#L13) · theorem shiftTerm

- [Lean/projects/arithmetic-fourier-rh/fragments/ExponentialCountTransfer.lean](projects/arithmetic-fourier-rh/fragments/ExponentialCountTransfer.lean#L6) · theorem weighted_exponential_from_counts

- [Lean/projects/arithmetic-fourier-rh/fragments/FactorialSpine.lean](projects/arithmetic-fourier-rh/fragments/FactorialSpine.lean#L12) · theorem log_factorial

- [Lean/projects/arithmetic-fourier-rh/fragments/FiniteCarrier.lean](projects/arithmetic-fourier-rh/fragments/FiniteCarrier.lean#L13) · theorem allOnes_sq

- [Lean/projects/arithmetic-fourier-rh/fragments/FinitePerronMertens.lean](projects/arithmetic-fourier-rh/fragments/FinitePerronMertens.lean#L11) · theorem finite_probe_re

- [Lean/projects/arithmetic-fourier-rh/fragments/FinitePerronRectangle.lean](projects/arithmetic-fourier-rh/fragments/FinitePerronRectangle.lean#L10) · theorem central_vertical_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/FinitePerronTails.lean](projects/arithmetic-fourier-rh/fragments/FinitePerronTails.lean#L10) · theorem integral_tails_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/FinitePrimeSupport.lean](projects/arithmetic-fourier-rh/fragments/FinitePrimeSupport.lean#L7) · theorem primeTest_eq_finite_sum

- [Lean/projects/arithmetic-fourier-rh/fragments/FiniteSpectralTailObstruction.lean](projects/arithmetic-fourier-rh/fragments/FiniteSpectralTailObstruction.lean#L15) · theorem integrableOn_mul_bump

- [Lean/projects/arithmetic-fourier-rh/fragments/FiniteZeroPotential.lean](projects/arithmetic-fourier-rh/fragments/FiniteZeroPotential.lean#L12) · theorem finite_zero_potential_lipschitz

- [Lean/projects/arithmetic-fourier-rh/fragments/FixedStripChebyshev.lean](projects/arithmetic-fourier-rh/fragments/FixedStripChebyshev.lean#L10) · theorem chebyshev_power_bound_of_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/FixedStripFourierGrowth.lean](projects/arithmetic-fourier-rh/fragments/FixedStripFourierGrowth.lean#L9) · theorem smoothed_mertens_bound_of_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/FixedStripLogDerivative.lean](projects/arithmetic-fourier-rh/fragments/FixedStripLogDerivative.lean#L10) · theorem logDeriv_strip_borel_on_centered_sphere

- [Lean/projects/arithmetic-fourier-rh/fragments/FixedStripReciprocal.lean](projects/arithmetic-fourier-rh/fragments/FixedStripReciprocal.lean#L8) · theorem strip_borel_on_centered_sphere

- [Lean/projects/arithmetic-fourier-rh/fragments/FixedStripTraceEquivalence.lean](projects/arithmetic-fourier-rh/fragments/FixedStripTraceEquivalence.lean#L7) · theorem fixed_strip_trace_iff_of_full

- [Lean/projects/arithmetic-fourier-rh/fragments/FourierDecay.lean](projects/arithmetic-fourier-rh/fragments/FourierDecay.lean#L12) · theorem uniform_quadratic_decay

- [Lean/projects/arithmetic-fourier-rh/fragments/FourierEulerFactor.lean](projects/arithmetic-fourier-rh/fragments/FourierEulerFactor.lean#L11) · theorem abscissa_le_zero_of_inverse_majorant

- [Lean/projects/arithmetic-fourier-rh/fragments/FourierTestInversion.lean](projects/arithmetic-fourier-rh/fragments/FourierTestInversion.lean#L17) · theorem phase_norm

- [Lean/projects/arithmetic-fourier-rh/fragments/FreezeActualSpectralRows.lean](projects/arithmetic-fourier-rh/fragments/FreezeActualSpectralRows.lean#L21) · theorem right_height_mono

- [Lean/projects/arithmetic-fourier-rh/fragments/FrozenPotentialShift.lean](projects/arithmetic-fourier-rh/fragments/FrozenPotentialShift.lean#L7) · theorem right_potential_frozen_lipschitz

- [Lean/projects/arithmetic-fourier-rh/fragments/FrozenRankWindowTransfer.lean](projects/arithmetic-fourier-rh/fragments/FrozenRankWindowTransfer.lean#L12) · theorem frozen_rank_window_obstruction

- [Lean/projects/arithmetic-fourier-rh/fragments/FrozenShellGridError.lean](projects/arithmetic-fourier-rh/fragments/FrozenShellGridError.lean#L13) · theorem shell_signal_at_nat

- [Lean/projects/arithmetic-fourier-rh/fragments/FrozenWindowObstruction.lean](projects/arithmetic-fourier-rh/fragments/FrozenWindowObstruction.lean#L13) · theorem frozen_window_isolates_zero_contrast

- [Lean/projects/arithmetic-fourier-rh/fragments/GammaSeqLogDerivative.lean](projects/arithmetic-fourier-rh/fragments/GammaSeqLogDerivative.lean#L8) · theorem factor_ne

- [Lean/projects/arithmetic-fourier-rh/fragments/GammaSeqUniform.lean](projects/arithmetic-fourier-rh/fragments/GammaSeqUniform.lean#L15) · theorem approximand_integrable

- [Lean/projects/arithmetic-fourier-rh/fragments/GaussComponents.lean](projects/arithmetic-fourier-rh/fragments/GaussComponents.lean#L7) · theorem nontrivial_character_product

- [Lean/projects/arithmetic-fourier-rh/fragments/GenericSpectralFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/GenericSpectralFourierPairing.lean#L9) · theorem relative_vertical_norm_le_of_re_lt_one

- [Lean/projects/arithmetic-fourier-rh/fragments/GenericThreeHalvesSum.lean](projects/arithmetic-fourier-rh/fragments/GenericThreeHalvesSum.lean#L15) · theorem inverse_three_halves_with_multiplicity

- [Lean/projects/arithmetic-fourier-rh/fragments/GeometricPoleLimit.lean](projects/arithmetic-fourier-rh/fragments/GeometricPoleLimit.lean#L9) · theorem poleTest_limit

- [Lean/projects/arithmetic-fourier-rh/fragments/HadamardGrowthConsequence.lean](projects/arithmetic-fourier-rh/fragments/HadamardGrowthConsequence.lean#L8) · theorem subquadratic_mean_of_three_halves_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/HadamardRelative.lean](projects/arithmetic-fourier-rh/fragments/HadamardRelative.lean#L10) · theorem entireXi_logDerivative_of_hadamard

- [Lean/projects/arithmetic-fourier-rh/fragments/HurwitzMellinEnvelope.lean](projects/arithmetic-fourier-rh/fragments/HurwitzMellinEnvelope.lean#L8) · theorem upperF_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/HurwitzTailGrowth.lean](projects/arithmetic-fourier-rh/fragments/HurwitzTailGrowth.lean#L8) · theorem exp_bound_above_one

- [Lean/projects/arithmetic-fourier-rh/fragments/IntegerPhaseSampling.lean](projects/arithmetic-fourier-rh/fragments/IntegerPhaseSampling.lean#L7) · theorem ceil_exp_phase_sample

- [Lean/projects/arithmetic-fourier-rh/fragments/IntegerWindowObserver.lean](projects/arithmetic-fourier-rh/fragments/IntegerWindowObserver.lean#L14) · theorem real_power_implies_natural_power

- [Lean/projects/arithmetic-fourier-rh/fragments/JensenZeroCount.lean](projects/arithmetic-fourier-rh/fragments/JensenZeroCount.lean#L9) · theorem jensen_finite_subset

- [Lean/projects/arithmetic-fourier-rh/fragments/LineResidualEquivalence.lean](projects/arithmetic-fourier-rh/fragments/LineResidualEquivalence.lean#L8) · theorem full_zeta_euler_residual_limit

- [Lean/projects/arithmetic-fourier-rh/fragments/LocalizedCrossingGroups.lean](projects/arithmetic-fourier-rh/fragments/LocalizedCrossingGroups.lean#L11) · theorem localized_groups

- [Lean/projects/arithmetic-fourier-rh/fragments/LogDerivativeObstruction.lean](projects/arithmetic-fourier-rh/fragments/LogDerivativeObstruction.lean#L6) · theorem no_finite_zero_of_logDerivative

- [Lean/projects/arithmetic-fourier-rh/fragments/LongRankGridConnection.lean](projects/arithmetic-fourier-rh/fragments/LongRankGridConnection.lean#L9) · theorem row_grid_connection

- [Lean/projects/arithmetic-fourier-rh/fragments/LongRankStripEquivalence.lean](projects/arithmetic-fourier-rh/fragments/LongRankStripEquivalence.lean#L14) · theorem uniform_long_row_power_forces_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/LongRankStripForward.lean](projects/arithmetic-fourier-rh/fragments/LongRankStripForward.lean#L9) · theorem nonnegative_row_weight

- [Lean/projects/arithmetic-fourier-rh/fragments/MellinGrowth.lean](projects/arithmetic-fourier-rh/fragments/MellinGrowth.lean#L7) · theorem power_exp_majorant

- [Lean/projects/arithmetic-fourier-rh/fragments/MertensConverse.lean](projects/arithmetic-fourier-rh/fragments/MertensConverse.lean#L7) · theorem mertens_power_bound_of_RH

- [Lean/projects/arithmetic-fourier-rh/fragments/MertensFixedPower.lean](projects/arithmetic-fourier-rh/fragments/MertensFixedPower.lean#L15) · theorem power_cut_mertens_local

- [Lean/projects/arithmetic-fourier-rh/fragments/MertensRampApproximation.lean](projects/arithmetic-fourier-rh/fragments/MertensRampApproximation.lean#L10) · theorem smoothedMertens_error

- [Lean/projects/arithmetic-fourier-rh/fragments/MertensToZetaResidual.lean](projects/arithmetic-fourier-rh/fragments/MertensToZetaResidual.lean#L22) · theorem cut_local

- [Lean/projects/arithmetic-fourier-rh/fragments/MixedRadix.lean](projects/arithmetic-fourier-rh/fragments/MixedRadix.lean#L14) · theorem mixed_column_at_two

- [Lean/projects/arithmetic-fourier-rh/fragments/MobiusCrossingLengths.lean](projects/arithmetic-fourier-rh/fragments/MobiusCrossingLengths.lean#L10) · theorem index_gap

- [Lean/projects/arithmetic-fourier-rh/fragments/MobiusRankLocalization.lean](projects/arithmetic-fourier-rh/fragments/MobiusRankLocalization.lean#L10) · theorem prefix_stable

- [Lean/projects/arithmetic-fourier-rh/fragments/Mollifier.lean](projects/arithmetic-fourier-rh/fragments/Mollifier.lean#L17) · theorem epsilon_pos

- [Lean/projects/arithmetic-fourier-rh/fragments/MollifierBulkBounds.lean](projects/arithmetic-fourier-rh/fragments/MollifierBulkBounds.lean#L12) · theorem bulk_zero

- [Lean/projects/arithmetic-fourier-rh/fragments/MultiplicityMajorant.lean](projects/arithmetic-fourier-rh/fragments/MultiplicityMajorant.lean#L13) · theorem heightBin_upper

- [Lean/projects/arithmetic-fourier-rh/fragments/NaturalLongRankStripEquivalence.lean](projects/arithmetic-fourier-rh/fragments/NaturalLongRankStripEquivalence.lean#L15) · theorem uniform_natural_long_row_power_forces_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/NontrivialZeroExistence.lean](projects/arithmetic-fourier-rh/fragments/NontrivialZeroExistence.lean#L9) · theorem entireXi_at_two

- [Lean/projects/arithmetic-fourier-rh/fragments/NormalizedEntireQuotient.lean](projects/arithmetic-fourier-rh/fragments/NormalizedEntireQuotient.lean#L12) · theorem entire_unit_log

- [Lean/projects/arithmetic-fourier-rh/fragments/ObservableLongRows.lean](projects/arithmetic-fourier-rh/fragments/ObservableLongRows.lean#L7) · theorem pair_mem_rank_rows

- [Lean/projects/arithmetic-fourier-rh/fragments/OneSidedDyadicPower.lean](projects/arithmetic-fourier-rh/fragments/OneSidedDyadicPower.lean#L11) · theorem signed_dyadic_to_endpoint_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/OneSidedFourierScalar.lean](projects/arithmetic-fourier-rh/fragments/OneSidedFourierScalar.lean#L14) · theorem real_fourier_scalar_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/OneSidedNaturalDyadic.lean](projects/arithmetic-fourier-rh/fragments/OneSidedNaturalDyadic.lean#L9) · theorem psi_nat_succ

- [Lean/projects/arithmetic-fourier-rh/fragments/OneSidedPrimePower.lean](projects/arithmetic-fourier-rh/fragments/OneSidedPrimePower.lean#L8) · theorem zero_free_of_signed_prime_power

- [Lean/projects/arithmetic-fourier-rh/fragments/OneSidedRHCriteria.lean](projects/arithmetic-fourier-rh/fragments/OneSidedRHCriteria.lean#L10) · theorem fixed_strip_iff_one_sided_fourier_scalar

- [Lean/projects/arithmetic-fourier-rh/fragments/OptimalFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/OptimalFourierPairing.lean#L11) · theorem muR_signs

- [Lean/projects/arithmetic-fourier-rh/fragments/ParameterHolomorphy.lean](projects/arithmetic-fourier-rh/fragments/ParameterHolomorphy.lean#L12) · theorem logTest_eq_clamped

- [Lean/projects/arithmetic-fourier-rh/fragments/ParametricAmplitudeCriterion.lean](projects/arithmetic-fourier-rh/fragments/ParametricAmplitudeCriterion.lean#L15) · theorem paramRightSum_eq_zero_of_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/ParametricSharpDyadic.lean](projects/arithmetic-fourier-rh/fragments/ParametricSharpDyadic.lean#L19) · theorem at_width

- [Lean/projects/arithmetic-fourier-rh/fragments/ParametricSharpZeroRemainder.lean](projects/arithmetic-fourier-rh/fragments/ParametricSharpZeroRemainder.lean#L15) · theorem paramRightSet_finite

- [Lean/projects/arithmetic-fourier-rh/fragments/ParametricSignedSharp.lean](projects/arithmetic-fourier-rh/fragments/ParametricSignedSharp.lean#L16) · theorem at_width

- [Lean/projects/arithmetic-fourier-rh/fragments/ParityRealPlace.lean](projects/arithmetic-fourier-rh/fragments/ParityRealPlace.lean#L11) · theorem parityRealPlaceKernel_even

- [Lean/projects/arithmetic-fourier-rh/fragments/ParityRealPlaceFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/ParityRealPlaceFourierPairing.lean#L8) · theorem parity_frequency_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/PerronGrowthTransfer.lean](projects/arithmetic-fourier-rh/fragments/PerronGrowthTransfer.lean#L13) · theorem kernel_eq_bounds

- [Lean/projects/arithmetic-fourier-rh/fragments/PerronRamp.lean](projects/arithmetic-fourier-rh/fragments/PerronRamp.lean#L13) · theorem ramp_continuous

- [Lean/projects/arithmetic-fourier-rh/fragments/PerronRampBounds.lean](projects/arithmetic-fourier-rh/fragments/PerronRampBounds.lean#L14) · theorem denominator_norm

- [Lean/projects/arithmetic-fourier-rh/fragments/PerronRampIntegral.lean](projects/arithmetic-fourier-rh/fragments/PerronRampIntegral.lean#L10) · theorem positive_half

- [Lean/projects/arithmetic-fourier-rh/fragments/PhaseDensityTransfer.lean](projects/arithmetic-fourier-rh/fragments/PhaseDensityTransfer.lean#L8) · theorem opposite_offsets_summable_of_sqrt_count

- [Lean/projects/arithmetic-fourier-rh/fragments/PhaseWindow.lean](projects/arithmetic-fourier-rh/fragments/PhaseWindow.lean#L19) · theorem applyWindowFold_cons

- [Lean/projects/arithmetic-fourier-rh/fragments/PhaseWindowFactors.lean](projects/arithmetic-fourier-rh/fragments/PhaseWindowFactors.lean#L12) · theorem opposite_offset_positive

- [Lean/projects/arithmetic-fourier-rh/fragments/PoleCompensation.lean](projects/arithmetic-fourier-rh/fragments/PoleCompensation.lean#L13) · theorem trace_rearrangement

- [Lean/projects/arithmetic-fourier-rh/fragments/PositiveComplexLaplace.lean](projects/arithmetic-fourier-rh/fragments/PositiveComplexLaplace.lean#L13) · theorem complex_laplace_analytic

- [Lean/projects/arithmetic-fourier-rh/fragments/PositiveLaplaceMoments.lean](projects/arithmetic-fourier-rh/fragments/PositiveLaplaceMoments.lean#L15) · theorem momentTerm_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/PositiveSummatoryPower.lean](projects/arithmetic-fourier-rh/fragments/PositiveSummatoryPower.lean#L18) · theorem power_density_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/PositivityBalance.lean](projects/arithmetic-fourier-rh/fragments/PositivityBalance.lean#L6) · theorem main_lower_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeAtomBumps.lean](projects/arithmetic-fourier-rh/fragments/PrimeAtomBumps.lean#L13) · theorem center_pos

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeAtomValue.lean](projects/arithmetic-fourier-rh/fragments/PrimeAtomValue.lean#L6) · theorem prime_sum_eq_halfWeight_two

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeErrorLaplace.lean](projects/arithmetic-fourier-rh/fragments/PrimeErrorLaplace.lean#L11) · theorem real_prime_error_at_nat

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeErrorSignChanges.lean](projects/arithmetic-fourier-rh/fragments/PrimeErrorSignChanges.lean#L16) · theorem density_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/PrimeFourierPairing.lean#L11) · theorem prime_shift_term

- [Lean/projects/arithmetic-fourier-rh/fragments/PrimeHalfShellCount.lean](projects/arithmetic-fourier-rh/fragments/PrimeHalfShellCount.lean#L9) · theorem theta_ratio_tendsto_one

- [Lean/projects/arithmetic-fourier-rh/fragments/ProbabilityKernel.lean](projects/arithmetic-fourier-rh/fragments/ProbabilityKernel.lean#L10) · theorem probability_kernel_weighted_mass

- [Lean/projects/arithmetic-fourier-rh/fragments/QuantitativeMertens.lean](projects/arithmetic-fourier-rh/fragments/QuantitativeMertens.lean#L11) · theorem finite_height_factor

- [Lean/projects/arithmetic-fourier-rh/fragments/QuotientMeanGrowth.lean](projects/arithmetic-fourier-rh/fragments/QuotientMeanGrowth.lean#L8) · theorem circleAverage_log_norm_nonneg_of_one

- [Lean/projects/arithmetic-fourier-rh/fragments/RadixActualRankPairing.lean](projects/arithmetic-fourier-rh/fragments/RadixActualRankPairing.lean#L16) · theorem index_mem

- [Lean/projects/arithmetic-fourier-rh/fragments/RadixFloor.lean](projects/arithmetic-fourier-rh/fragments/RadixFloor.lean#L11) · theorem test_mod

- [Lean/projects/arithmetic-fourier-rh/fragments/RadixMellin.lean](projects/arithmetic-fourier-rh/fragments/RadixMellin.lean#L12) · theorem residue_mod

- [Lean/projects/arithmetic-fourier-rh/fragments/RadixSampling.lean](projects/arithmetic-fourier-rh/fragments/RadixSampling.lean#L7) · theorem weight_at_rational_sample

- [Lean/projects/arithmetic-fourier-rh/fragments/RankCenteredContrast.lean](projects/arithmetic-fourier-rh/fragments/RankCenteredContrast.lean#L14) · theorem centered_mean

- [Lean/projects/arithmetic-fourier-rh/fragments/RankContrastTransfer.lean](projects/arithmetic-fourier-rh/fragments/RankContrastTransfer.lean#L9) · theorem contrast_add

- [Lean/projects/arithmetic-fourier-rh/fragments/RankFittedConstant.lean](projects/arithmetic-fourier-rh/fragments/RankFittedConstant.lean#L14) · theorem fitted_constant_identity

- [Lean/projects/arithmetic-fourier-rh/fragments/RankGroupMean.lean](projects/arithmetic-fourier-rh/fragments/RankGroupMean.lean#L9) · theorem difference_of_group_means

- [Lean/projects/arithmetic-fourier-rh/fragments/RankNormalizedGeometry.lean](projects/arithmetic-fourier-rh/fragments/RankNormalizedGeometry.lean#L7) · theorem normalized_reciprocal_gap

- [Lean/projects/arithmetic-fourier-rh/fragments/RankPairingCore.lean](projects/arithmetic-fourier-rh/fragments/RankPairingCore.lean#L11) · theorem mem_crossings

- [Lean/projects/arithmetic-fourier-rh/fragments/RankScaleWindow.lean](projects/arithmetic-fourier-rh/fragments/RankScaleWindow.lean#L14) · theorem central_scale_relation

- [Lean/projects/arithmetic-fourier-rh/fragments/RankStripAsymptotics.lean](projects/arithmetic-fourier-rh/fragments/RankStripAsymptotics.lean#L7) · theorem nominalQ_nat_atTop

- [Lean/projects/arithmetic-fourier-rh/fragments/RankStripFourierConnection.lean](projects/arithmetic-fourier-rh/fragments/RankStripFourierConnection.lean#L10) · theorem natural_rank_saving_forces_fourier_scalar

- [Lean/projects/arithmetic-fourier-rh/fragments/RealDyadicMesh.lean](projects/arithmetic-fourier-rh/fragments/RealDyadicMesh.lean#L15) · theorem real_dyadic_mesh

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceBranches.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceBranches.lean#L6) · theorem parityRealPlaceKernel_branch_formula

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceFourierPairing.lean#L10) · theorem frequency_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceHolomorphic.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceHolomorphic.lean#L9) · theorem realPlaceKernel_mul_x_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceLimit.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceLimit.lean#L10) · theorem realPlaceKernel_nonneg

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceLogGrowth.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceLogGrowth.lean#L9) · theorem realPlaceRelative_log_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/RealPlaceSeries.lean](projects/arithmetic-fourier-rh/fragments/RealPlaceSeries.lean#L10) · theorem archWeight_hasSum

- [Lean/projects/arithmetic-fourier-rh/fragments/RealRankCenter.lean](projects/arithmetic-fourier-rh/fragments/RealRankCenter.lean#L12) · theorem right_conjugate_involutive

- [Lean/projects/arithmetic-fourier-rh/fragments/RealRetainedSpectral.lean](projects/arithmetic-fourier-rh/fragments/RealRetainedSpectral.lean#L11) · theorem compact_zero_term_conjugate

- [Lean/projects/arithmetic-fourier-rh/fragments/ReciprocalEulerDisk.lean](projects/arithmetic-fourier-rh/fragments/ReciprocalEulerDisk.lean#L6) · theorem euler_reciprocal_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ReciprocalHighLogStrip.lean](projects/arithmetic-fourier-rh/fragments/ReciprocalHighLogStrip.lean#L7) · theorem euler_envelope

- [Lean/projects/arithmetic-fourier-rh/fragments/ReciprocalLocalComparison.lean](projects/arithmetic-fourier-rh/fragments/ReciprocalLocalComparison.lean#L6) · theorem borel_on_centered_sphere

- [Lean/projects/arithmetic-fourier-rh/fragments/ReciprocalMovingDisk.lean](projects/arithmetic-fourier-rh/fragments/ReciprocalMovingDisk.lean#L7) · theorem exists_nonzero_log_region

- [Lean/projects/arithmetic-fourier-rh/fragments/ReciprocalUniformLogStrip.lean](projects/arithmetic-fourier-rh/fragments/ReciprocalUniformLogStrip.lean#L7) · theorem reciprocal_analytic_of_nonzero

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeAnalytic.lean](projects/arithmetic-fourier-rh/fragments/RelativeAnalytic.lean#L8) · theorem logTest_continuous

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeGammaFactor.lean](projects/arithmetic-fourier-rh/fragments/RelativeGammaFactor.lean#L7) · theorem gammaSeq_logDerivative_tendsto

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeLaplace.lean](projects/arithmetic-fourier-rh/fragments/RelativeLaplace.lean#L8) · theorem laplace_difference

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeResolvent.lean](projects/arithmetic-fourier-rh/fragments/RelativeResolvent.lean#L10) · theorem reference_subtraction

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeSpectrumAnalytic.lean](projects/arithmetic-fourier-rh/fragments/RelativeSpectrumAnalytic.lean#L13) · theorem relative_hasSum_locallyUniformlyOn

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeSpectrumRigidity.lean](projects/arithmetic-fourier-rh/fragments/RelativeSpectrumRigidity.lean#L8) · theorem spectrum_coefficients_zero_of_germ

- [Lean/projects/arithmetic-fourier-rh/fragments/RelativeVerticalMajorant.lean](projects/arithmetic-fourier-rh/fragments/RelativeVerticalMajorant.lean#L6) · theorem relative_vertical_norm_le

- [Lean/projects/arithmetic-fourier-rh/fragments/ResolventFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/ResolventFourierPairing.lean#L9) · theorem verticalProbe_re

- [Lean/projects/arithmetic-fourier-rh/fragments/RestrictedTraceEquivalence.lean](projects/arithmetic-fourier-rh/fragments/RestrictedTraceEquivalence.lean#L10) · theorem zeta_restricted_trace_of_RH

- [Lean/projects/arithmetic-fourier-rh/fragments/RestrictedTraceLimit.lean](projects/arithmetic-fourier-rh/fragments/RestrictedTraceLimit.lean#L11) · theorem restrictedTraceLimit_analytic

- [Lean/projects/arithmetic-fourier-rh/fragments/RestrictedTraceZeroFree.lean](projects/arithmetic-fourier-rh/fragments/RestrictedTraceZeroFree.lean#L14) · theorem zero_free_from_restricted_finite_trace

- [Lean/projects/arithmetic-fourier-rh/fragments/RetainedAmplitudeCriterion.lean](projects/arithmetic-fourier-rh/fragments/RetainedAmplitudeCriterion.lean#L13) · theorem psi_eq_coe_chebyshev

- [Lean/projects/arithmetic-fourier-rh/fragments/RieszFiniteRamp.lean](projects/arithmetic-fourier-rh/fragments/RieszFiniteRamp.lean#L8) · theorem integrate_prime_atom

- [Lean/projects/arithmetic-fourier-rh/fragments/RieszNaturalRounding.lean](projects/arithmetic-fourier-rh/fragments/RieszNaturalRounding.lean#L8) · theorem prime_error_integral_linear

- [Lean/projects/arithmetic-fourier-rh/fragments/RieszPrimeMellin.lean](projects/arithmetic-fourier-rh/fragments/RieszPrimeMellin.lean#L10) · theorem rieszError_measurable

- [Lean/projects/arithmetic-fourier-rh/fragments/RieszSignedCriterion.lean](projects/arithmetic-fourier-rh/fragments/RieszSignedCriterion.lean#L9) · theorem zero_free_of_one_sided_riesz_power

- [Lean/projects/arithmetic-fourier-rh/fragments/ScaledCompactTest.lean](projects/arithmetic-fourier-rh/fragments/ScaledCompactTest.lean#L11) · theorem scaleTest_smooth

- [Lean/projects/arithmetic-fourier-rh/fragments/ScaledCutoff.lean](projects/arithmetic-fourier-rh/fragments/ScaledCutoff.lean#L12) · theorem cutoffScaled_eq

- [Lean/projects/arithmetic-fourier-rh/fragments/SharpChebyshevError.lean](projects/arithmetic-fourier-rh/fragments/SharpChebyshevError.lean#L12) · theorem smooth_shell_error

- [Lean/projects/arithmetic-fourier-rh/fragments/SharpPrimeNumberTheorem.lean](projects/arithmetic-fourier-rh/fragments/SharpPrimeNumberTheorem.lean#L12) · theorem primeCut_sum

- [Lean/projects/arithmetic-fourier-rh/fragments/SharpRetainedStripBound.lean](projects/arithmetic-fourier-rh/fragments/SharpRetainedStripBound.lean#L8) · theorem retained_bound_of_strip

- [Lean/projects/arithmetic-fourier-rh/fragments/SignedModeExcursions.lean](projects/arithmetic-fourier-rh/fragments/SignedModeExcursions.lean#L9) · theorem zero_free_of_fixed_signed_mode

- [Lean/projects/arithmetic-fourier-rh/fragments/SignedRetainedCriterion.lean](projects/arithmetic-fourier-rh/fragments/SignedRetainedCriterion.lean#L14) · theorem signed_mode_bounds_prime_error

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothCandidate.lean](projects/arithmetic-fourier-rh/fragments/SmoothCandidate.lean#L17) · theorem delayed_vanishes_left

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedLSeriesEuler.lean](projects/arithmetic-fourier-rh/fragments/SmoothedLSeriesEuler.lean#L13) · theorem lseries_perron_term_identity

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPerronEuler.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPerronEuler.lean#L11) · theorem probe_re

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPerronShift.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPerronShift.lean#L10) · theorem kernel_eq_bounds

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPoleApproximation.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPoleApproximation.lean#L9) · theorem poleCut_integrable

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPoleEuler.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPoleEuler.lean#L11) · theorem smoothedPole_euler_pairing

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPrimeError.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPrimeError.lean#L14) · theorem scaled_zero_sum_exp_sqrt_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPrimeExplicitLimit.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPrimeExplicitLimit.lean#L8) · theorem scaled_real_place_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPrimeSandwichUniform.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPrimeSandwichUniform.lean#L13) · theorem shell_smooth

- [Lean/projects/arithmetic-fourier-rh/fragments/SmoothedPrimeUniform.lean](projects/arithmetic-fourier-rh/fragments/SmoothedPrimeUniform.lean#L15) · theorem uniform_zero_sum

- [Lean/projects/arithmetic-fourier-rh/fragments/SpectralCarrierDomain.lean](projects/arithmetic-fourier-rh/fragments/SpectralCarrierDomain.lean#L7) · theorem range_closed_of_radially_finite

- [Lean/projects/arithmetic-fourier-rh/fragments/SpectralFourierPairing.lean](projects/arithmetic-fourier-rh/fragments/SpectralFourierPairing.lean#L9) · theorem pair_zetaSpectralRelative

- [Lean/projects/arithmetic-fourier-rh/fragments/SpectralHolomorphic.lean](projects/arithmetic-fourier-rh/fragments/SpectralHolomorphic.lean#L7) · theorem relative_spectral_analytic

- [Lean/projects/arithmetic-fourier-rh/fragments/SpectralSum.lean](projects/arithmetic-fourier-rh/fragments/SpectralSum.lean#L6) · theorem weighted_spectral_sum_limit

- [Lean/projects/arithmetic-fourier-rh/fragments/SpectralTail.lean](projects/arithmetic-fourier-rh/fragments/SpectralTail.lean#L13) · theorem dyadic_summable

- [Lean/projects/arithmetic-fourier-rh/fragments/SquarefreeIntervalActivity.lean](projects/arithmetic-fourier-rh/fragments/SquarefreeIntervalActivity.lean#L6) · theorem interval_multiples_card

- [Lean/projects/arithmetic-fourier-rh/fragments/StripDerivativeWitness.lean](projects/arithmetic-fourier-rh/fragments/StripDerivativeWitness.lean#L12) · theorem derivativeMass_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/StripEvaluationWitness.lean](projects/arithmetic-fourier-rh/fragments/StripEvaluationWitness.lean#L15) · theorem witness_entire

- [Lean/projects/arithmetic-fourier-rh/fragments/StripObstructionExponent.lean](projects/arithmetic-fourier-rh/fragments/StripObstructionExponent.lean#L7) · theorem choose_strip_obstruction_parameters

- [Lean/projects/arithmetic-fourier-rh/fragments/ThreeConditionTrim.lean](projects/arithmetic-fourier-rh/fragments/ThreeConditionTrim.lean#L12) · theorem discard_three_conditions

- [Lean/projects/arithmetic-fourier-rh/fragments/TransformLimit.lean](projects/arithmetic-fourier-rh/fragments/TransformLimit.lean#L9) · theorem fullCandidate_exponential_envelope

- [Lean/projects/arithmetic-fourier-rh/fragments/UnconditionalDyadicLogSaving.lean](projects/arithmetic-fourier-rh/fragments/UnconditionalDyadicLogSaving.lean#L8) · theorem prime_remainder_log_power

- [Lean/projects/arithmetic-fourier-rh/fragments/UnconditionalMertens.lean](projects/arithmetic-fourier-rh/fragments/UnconditionalMertens.lean#L10) · theorem quantitative_mertens

- [Lean/projects/arithmetic-fourier-rh/fragments/UnconditionalRankRestricted.lean](projects/arithmetic-fourier-rh/fragments/UnconditionalRankRestricted.lean#L9) · theorem quantitative_mertens_at_dyadic_cutoffs

- [Lean/projects/arithmetic-fourier-rh/fragments/UniformGridRounding.lean](projects/arithmetic-fourier-rh/fragments/UniformGridRounding.lean#L11) · theorem real_active_filter

- [Lean/projects/arithmetic-fourier-rh/fragments/UniformPhaseIsolation.lean](projects/arithmetic-fourier-rh/fragments/UniformPhaseIsolation.lean#L9) · theorem small_signed_window

- [Lean/projects/arithmetic-fourier-rh/fragments/UnrestrictedCompactPrimeLimit.lean](projects/arithmetic-fourier-rh/fragments/UnrestrictedCompactPrimeLimit.lean#L9) · theorem translate_compact

- [Lean/projects/arithmetic-fourier-rh/fragments/VerticalIntegralShift.lean](projects/arithmetic-fourier-rh/fragments/VerticalIntegralShift.lean#L10) · theorem horizontal_limit

- [Lean/projects/arithmetic-fourier-rh/fragments/WeakFEPairMellinSplit.lean](projects/arithmetic-fourier-rh/fragments/WeakFEPairMellinSplit.lean#L13) · theorem cut_convergent

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedBulk.lean](projects/arithmetic-fourier-rh/fragments/WeightedBulk.lean#L17) · theorem positiveFormula_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedBulkComplex.lean](projects/arithmetic-fourier-rh/fragments/WeightedBulkComplex.lean#L9) · theorem weighted_bulk_complex_integrable

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedConvolution.lean](projects/arithmetic-fourier-rh/fragments/WeightedConvolution.lean#L14) · theorem norm_weighted

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedFourierBounds.lean](projects/arithmetic-fourier-rh/fragments/WeightedFourierBounds.lean#L12) · theorem weighted_iteratedDeriv_mass

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedRegularity.lean](projects/arithmetic-fourier-rh/fragments/WeightedRegularity.lean#L11) · theorem iteratedDeriv_hasCompactSupport

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedRightDensity.lean](projects/arithmetic-fourier-rh/fragments/WeightedRightDensity.lean#L7) · theorem weighted_rank_density_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/WeightedVariancePairs.lean](projects/arithmetic-fourier-rh/fragments/WeightedVariancePairs.lean#L8) · theorem weighted_pair_difference_identity

- [Lean/projects/arithmetic-fourier-rh/fragments/WindowCostAlgebra.lean](projects/arithmetic-fourier-rh/fragments/WindowCostAlgebra.lean#L6) · theorem quarter_row_cost_algebra

- [Lean/projects/arithmetic-fourier-rh/fragments/WindowUniformObserver.lean](projects/arithmetic-fourier-rh/fragments/WindowUniformObserver.lean#L8) · theorem uniform_power_observes_scale_windows

- [Lean/projects/arithmetic-fourier-rh/fragments/XiEulerMatch.lean](projects/arithmetic-fourier-rh/fragments/XiEulerMatch.lean#L6) · theorem entireXi_logDerivative_euler

- [Lean/projects/arithmetic-fourier-rh/fragments/ZeroPrimitiveBounds.lean](projects/arithmetic-fourier-rh/fragments/ZeroPrimitiveBounds.lean#L8) · theorem log_mode_norm

- [Lean/projects/arithmetic-fourier-rh/fragments/ZeroPrimitiveMean.lean](projects/arithmetic-fourier-rh/fragments/ZeroPrimitiveMean.lean#L12) · theorem zero_primitive_derivative

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaAbelGrowth.lean](projects/arithmetic-fourier-rh/fragments/ZetaAbelGrowth.lean#L20) · theorem cut_local

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaCanonicalPositive.lean](projects/arithmetic-fourier-rh/fragments/ZetaCanonicalPositive.lean#L7) · theorem completed_logDerivative_real_lower

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaCanonicalProduct.lean](projects/arithmetic-fourier-rh/fragments/ZetaCanonicalProduct.lean#L14) · theorem zetaFactor_differentiable

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaConjugateMultiplicity.lean](projects/arithmetic-fourier-rh/fragments/ZetaConjugateMultiplicity.lean#L17) · theorem conjugateZeroEquiv_val

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaContinuationCriterion.lean](projects/arithmetic-fourier-rh/fragments/ZetaContinuationCriterion.lean#L8) · theorem puncturedRight_preconnected

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaDiskLog.lean](projects/arithmetic-fourier-rh/fragments/ZetaDiskLog.lean#L9) · theorem analytic_log_on_ball

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaEulerNearOne.lean](projects/arithmetic-fourier-rh/fragments/ZetaEulerNearOne.lean#L9) · theorem term_bound

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaFullFiniteFormula.lean](projects/arithmetic-fourier-rh/fragments/ZetaFullFiniteFormula.lean#L8) · theorem zeta_explicit_formula_compact

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaHadamardComplete.lean](projects/arithmetic-fourier-rh/fragments/ZetaHadamardComplete.lean#L7) · theorem zeta_hadamard_factorization

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaLogarithmicExclusion.lean](projects/arithmetic-fourier-rh/fragments/ZetaLogarithmicExclusion.lean#L7) · theorem vertical_im

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaLogarithmicRegion.lean](projects/arithmetic-fourier-rh/fragments/ZetaLogarithmicRegion.lean#L8) · theorem bounded_height_exclusion

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaMellinSplit.lean](projects/arithmetic-fourier-rh/fragments/ZetaMellinSplit.lean#L11) · theorem tail_eq_upper

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaOnMovingDisks.lean](projects/arithmetic-fourier-rh/fragments/ZetaOnMovingDisks.lean#L10) · theorem verticalCenter_re

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaPoleRemoved.lean](projects/arithmetic-fourier-rh/fragments/ZetaPoleRemoved.lean#L10) · theorem regularizedZeta_one

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaProductLogDerivative.lean](projects/arithmetic-fourier-rh/fragments/ZetaProductLogDerivative.lean#L9) · theorem zetaFactor_logDerivative

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaProductOrders.lean](projects/arithmetic-fourier-rh/fragments/ZetaProductOrders.lean#L10) · theorem zetaSubproduct_locally_uniform

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaProductZeros.lean](projects/arithmetic-fourier-rh/fragments/ZetaProductZeros.lean#L6) · theorem zetaFactor_eq_zero_iff

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaRadialSummability.lean](projects/arithmetic-fourier-rh/fragments/ZetaRadialSummability.lean#L6) · theorem zeta_zero_norm_lower

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaReciprocalSlowGrowth.lean](projects/arithmetic-fourier-rh/fragments/ZetaReciprocalSlowGrowth.lean#L8) · theorem borel_on_centered_sphere

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaReciprocalUniform.lean](projects/arithmetic-fourier-rh/fragments/ZetaReciprocalUniform.lean#L12) · theorem right_zero_free_of_RH

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaRightDensity.lean](projects/arithmetic-fourier-rh/fragments/ZetaRightDensity.lean#L20) · theorem log_fifth_third_le_sqrt

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaSpectralSum.lean](projects/arithmetic-fourier-rh/fragments/ZetaSpectralSum.lean#L10) · theorem zeta_nontrivial_zero_finite_order

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaSpectralWeightIdentification.lean](projects/arithmetic-fourier-rh/fragments/ZetaSpectralWeightIdentification.lean#L8) · theorem zeta_zero_radially_finite

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaThreeHalvesSum.lean](projects/arithmetic-fourier-rh/fragments/ZetaThreeHalvesSum.lean#L7) · theorem zeta_inverse_three_halves_with_multiplicity

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaThreePointPositivity.lean](projects/arithmetic-fourier-rh/fragments/ZetaThreePointPositivity.lean#L9) · theorem vertical_re

- [Lean/projects/arithmetic-fourier-rh/fragments/ZetaTraceCountDischarged.lean](projects/arithmetic-fourier-rh/fragments/ZetaTraceCountDischarged.lean#L6) · theorem zeta_spectral_test_limit

### crystal-strings (1)

- [Lean/projects/crystal-strings/SCD_9_7j_1_L01_L03_V1.lean](projects/crystal-strings/SCD_9_7j_1_L01_L03_V1.lean#L150) · theorem C1_of_halves

### energy-extensions (11)

- [Lean/projects/energy-extensions/CoherentEnergyFlipAndAlpha.lean](projects/energy-extensions/CoherentEnergyFlipAndAlpha.lean#L48) · theorem chiFactor_conj

- [Lean/projects/energy-extensions/CoherentEnergyRadiusMeasure.lean](projects/energy-extensions/CoherentEnergyRadiusMeasure.lean#L44) · theorem rhoProd_one

- [Lean/projects/energy-extensions/CoherentEnergyReflectionStrip.lean](projects/energy-extensions/CoherentEnergyReflectionStrip.lean#L43) · theorem rightHalfZeroFree_of_riemannHypothesis

- [Lean/projects/energy-extensions/CoherentEnergyRotatedCentre.lean](projects/energy-extensions/CoherentEnergyRotatedCentre.lean#L57) · theorem complexPoissonKernel_denom_pos

- [Lean/projects/energy-extensions/CoherentEnergySigmaBridge.lean](projects/energy-extensions/CoherentEnergySigmaBridge.lean#L42) · theorem rhoSigma_mem_Ico

- [Lean/projects/energy-extensions/ContinuationRotatedStatementPins.lean](projects/energy-extensions/ContinuationRotatedStatementPins.lean#L97) · theorem rightHalfZeroFree_eq

- [Lean/projects/energy-extensions/FiniteSphereFlipStatementPins.lean](projects/energy-extensions/FiniteSphereFlipStatementPins.lean#L44) · theorem finiteZetaFn_eq

- [Lean/projects/energy-extensions/FiniteSphereFlipV1.lean](projects/energy-extensions/FiniteSphereFlipV1.lean#L93) · theorem finiteZeta_functional_eq

- [Lean/projects/energy-extensions/R5ResonanceStatementPins.lean](projects/energy-extensions/R5ResonanceStatementPins.lean#L75) · theorem wProdFn_eq

- [Lean/projects/energy-extensions/R5SimpleZeroResonance.lean](projects/energy-extensions/R5SimpleZeroResonance.lean#L57) · theorem uZero_re

- [Lean/projects/energy-extensions/RadiusStatementPins.lean](projects/energy-extensions/RadiusStatementPins.lean#L77) · theorem rhoProd_eq

### Prime-phase joint port · Lean 4.33.1 (7)

- [Lean/projects/energy-joint-433/CoherentEnergyMeasure.lean](projects/energy-joint-433/CoherentEnergyMeasure.lean#L21) · theorem poissonKernel_denom_pos

- [Lean/projects/energy-joint-433/CoherentEnergyRHBridge.lean](projects/energy-joint-433/CoherentEnergyRHBridge.lean#L9) · theorem mertens_eq_M

- [Lean/projects/energy-joint-433/JointBridgeStatementPins.lean](projects/energy-joint-433/JointBridgeStatementPins.lean#L54) · theorem poissonKernelPin_eq

- [Lean/projects/energy-joint-433/JointCompat.lean](projects/energy-joint-433/JointCompat.lean#L4) · theorem ite_eq_left

- [Lean/projects/energy-joint-433/JointCompatImproper.lean](projects/energy-joint-433/JointCompatImproper.lean#L8) · theorem integrable_inv_one_add_mul_sq

- [Lean/projects/energy-joint-433/JointCorollary.lean](projects/energy-joint-433/JointCorollary.lean#L12) · theorem joint_energy_bound

- [Lean/projects/energy-joint-433/Verified.lean](projects/energy-joint-433/Verified.lean#L124) · theorem riemannHypothesis_of_right_zero_free

### factorial-oracle (4)

- [Lean/projects/factorial-oracle/FactorPath.lean](projects/factorial-oracle/FactorPath.lean#L17) · theorem firstLabel_eq_minFac

- [Lean/projects/factorial-oracle/FactorSearch.lean](projects/factorial-oracle/FactorSearch.lean#L14) · theorem exact_tooth_order

- [Lean/projects/factorial-oracle/FourierHelix.lean](projects/factorial-oracle/FourierHelix.lean#L14) · theorem phase_add

- [Lean/projects/factorial-oracle/WilsonOracle.lean](projects/factorial-oracle/WilsonOracle.lean#L17) · theorem distance_zero_iff

### farey-character-bridge (17)

- [Lean/projects/farey-character-bridge/CrystalBridge.lean](projects/farey-character-bridge/CrystalBridge.lean#L116) · theorem twistedCoprimeSum_sieve_prime

- [Lean/projects/farey-character-bridge/CrystalBridgeConverse.lean](projects/farey-character-bridge/CrystalBridgeConverse.lean#L10) · theorem allChiVCancellation_of_everyCharacter

- [Lean/projects/farey-character-bridge/CrystalBridgeConverseC1.lean](projects/farey-character-bridge/CrystalBridgeConverseC1.lean#L50) · theorem twistedS6_eq_sum_twistedMertens

- [Lean/projects/farey-character-bridge/CrystalBridgeConverseC2.lean](projects/farey-character-bridge/CrystalBridgeConverseC2.lean#L50) · theorem periodic_remainder_bound

- [Lean/projects/farey-character-bridge/CrystalBridgeConverseC3.lean](projects/farey-character-bridge/CrystalBridgeConverseC3.lean#L32) · theorem anchor_LFunction_sub_one

- [Lean/projects/farey-character-bridge/CrystalBridgeConverseC4.lean](projects/farey-character-bridge/CrystalBridgeConverseC4.lean#L24) · theorem reciprocal_eq

- [Lean/projects/farey-character-bridge/FranelBernoulli.lean](projects/farey-character-bridge/FranelBernoulli.lean#L13) · theorem gridSum_comm

- [Lean/projects/farey-character-bridge/FranelDiagonal.lean](projects/farey-character-bridge/FranelDiagonal.lean#L13) · theorem sqAr_apply

- [Lean/projects/farey-character-bridge/FranelEnergy.lean](projects/farey-character-bridge/FranelEnergy.lean#L12) · theorem franelEnergy_eq_coherent_energy

- [Lean/projects/farey-character-bridge/FranelGrids.lean](projects/farey-character-bridge/FranelGrids.lean#L26) · theorem repr_positive

- [Lean/projects/farey-character-bridge/FranelKernel.lean](projects/farey-character-bridge/FranelKernel.lean#L10) · def bTwo

- [Lean/projects/farey-character-bridge/FranelMertensBound.lean](projects/farey-character-bridge/FranelMertensBound.lean#L12) · theorem sum_rank_eq_grid

- [Lean/projects/farey-character-bridge/FranelPair.lean](projects/farey-character-bridge/FranelPair.lean#L10) · theorem weighted_pair_gcd

- [Lean/projects/farey-character-bridge/FranelPosition.lean](projects/farey-character-bridge/FranelPosition.lean#L10) · theorem grid_cos_zero

- [Lean/projects/farey-character-bridge/FranelRank.lean](projects/farey-character-bridge/FranelRank.lean#L7) · theorem bTwo_opposite

- [Lean/projects/farey-character-bridge/ThreeToothVernierBridge.lean](projects/farey-character-bridge/ThreeToothVernierBridge.lean#L437) · theorem threeToothEndpoint_eq_two_mul_twistedV

- [Lean/projects/farey-character-bridge/VernierPairingDirac.lean](projects/farey-character-bridge/VernierPairingDirac.lean#L553) · theorem diracMatrix_finrank_ker

### farey-orbit-contrast (5)

- [Lean/projects/farey-orbit-contrast/FareyOrbitPhasors.lean](projects/farey-orbit-contrast/FareyOrbitPhasors.lean#L21) · theorem periods_add

- [Lean/projects/farey-orbit-contrast/FareyOrbitSeven.lean](projects/farey-orbit-contrast/FareyOrbitSeven.lean#L77) · theorem order40

- [Lean/projects/farey-orbit-contrast/FareyQuadraticProjection.lean](projects/farey-orbit-contrast/FareyQuadraticProjection.lean#L63) · theorem quadraticCoefficient_eq

- [Lean/projects/farey-orbit-contrast/FareyRankInversion.lean](projects/farey-orbit-contrast/FareyRankInversion.lean#L54) · theorem countRank_eq_mertens_floors

- [Lean/projects/farey-orbit-contrast/TwistedCount.lean](projects/farey-orbit-contrast/TwistedCount.lean#L135) · theorem count_eq_floors

### farey-prime-character-energy (5)

- [Lean/projects/farey-prime-character-energy/FareyPrimeCharacterEnergy.lean](projects/farey-prime-character-energy/FareyPrimeCharacterEnergy.lean#L79) · theorem all_components_energy

- [Lean/projects/farey-prime-character-energy/FareyPrimeCharacterFormula.lean](projects/farey-prime-character-energy/FareyPrimeCharacterFormula.lean#L79) · theorem jointEnergy_eq_character_mertens

- [Lean/projects/farey-prime-character-energy/FareyPrimeCharacterParity.lean](projects/farey-prime-character-energy/FareyPrimeCharacterParity.lean#L91) · theorem principal_coefficient

- [Lean/projects/farey-prime-character-energy/PrimeQuadraticPeriods.lean](projects/farey-prime-character-energy/PrimeQuadraticPeriods.lean#L43) · theorem periods_sub_sq

- [Lean/projects/farey-prime-character-energy/TwistedCount.lean](projects/farey-prime-character-energy/TwistedCount.lean#L135) · theorem count_eq_floors

### Farey joint port · Lean 4.33.1 (17)

- [Lean/projects/farey-joint-433/Compose.lean](projects/farey-joint-433/Compose.lean#L18) · theorem everyCharacter_eq_upper

- [Lean/projects/farey-joint-433/CrystalBridge.lean](projects/farey-joint-433/CrystalBridge.lean#L116) · theorem twistedCoprimeSum_sieve_prime

- [Lean/projects/farey-joint-433/CrystalBridgeConverse.lean](projects/farey-joint-433/CrystalBridgeConverse.lean#L10) · theorem allChiVCancellation_of_everyCharacter

- [Lean/projects/farey-joint-433/CrystalBridgeConverseC1.lean](projects/farey-joint-433/CrystalBridgeConverseC1.lean#L50) · theorem twistedS6_eq_sum_twistedMertens

- [Lean/projects/farey-joint-433/CrystalBridgeConverseC2.lean](projects/farey-joint-433/CrystalBridgeConverseC2.lean#L50) · theorem periodic_remainder_bound

- [Lean/projects/farey-joint-433/CrystalBridgeConverseC3.lean](projects/farey-joint-433/CrystalBridgeConverseC3.lean#L32) · theorem anchor_LFunction_sub_one

- [Lean/projects/farey-joint-433/CrystalBridgeConverseC4.lean](projects/farey-joint-433/CrystalBridgeConverseC4.lean#L24) · theorem reciprocal_eq

- [Lean/projects/farey-joint-433/FranelBernoulli.lean](projects/farey-joint-433/FranelBernoulli.lean#L13) · theorem gridSum_comm

- [Lean/projects/farey-joint-433/FranelDiagonal.lean](projects/farey-joint-433/FranelDiagonal.lean#L13) · theorem sqAr_apply

- [Lean/projects/farey-joint-433/FranelEnergy.lean](projects/farey-joint-433/FranelEnergy.lean#L12) · theorem franelEnergy_eq_coherent_energy

- [Lean/projects/farey-joint-433/FranelGrids.lean](projects/farey-joint-433/FranelGrids.lean#L26) · theorem repr_positive

- [Lean/projects/farey-joint-433/FranelKernel.lean](projects/farey-joint-433/FranelKernel.lean#L10) · def bTwo

- [Lean/projects/farey-joint-433/FranelMertensBound.lean](projects/farey-joint-433/FranelMertensBound.lean#L12) · theorem sum_rank_eq_grid

- [Lean/projects/farey-joint-433/FranelPair.lean](projects/farey-joint-433/FranelPair.lean#L10) · theorem weighted_pair_gcd

- [Lean/projects/farey-joint-433/FranelPosition.lean](projects/farey-joint-433/FranelPosition.lean#L10) · theorem grid_cos_zero

- [Lean/projects/farey-joint-433/FranelRank.lean](projects/farey-joint-433/FranelRank.lean#L7) · theorem bTwo_opposite

- [Lean/projects/farey-joint-433/Verified.lean](projects/farey-joint-433/Verified.lean#L128) · theorem allOnes_sq

### mobius-lift-diagonal (2)

- [Lean/projects/mobius-lift-diagonal/Checks.lean](projects/mobius-lift-diagonal/Checks.lean#L5) · #print axioms

- [Lean/projects/mobius-lift-diagonal/MobiusLiftDiagonal.lean](projects/mobius-lift-diagonal/MobiusLiftDiagonal.lean#L21) · theorem diagonalLift_eval

### pen-gauss (10)

- [Lean/projects/pen-gauss/Audit.lean](projects/pen-gauss/Audit.lean#L5) · #check @pen_char_props

- [Lean/projects/pen-gauss/FourierHelix.lean](projects/pen-gauss/FourierHelix.lean#L14) · theorem phase_add

- [Lean/projects/pen-gauss/FVLT.lean](projects/pen-gauss/FVLT.lean#L1) · import FVLT.PenGaussV1

- [Lean/projects/pen-gauss/FVLT/PenGaussCore.lean](projects/pen-gauss/FVLT/PenGaussCore.lean#L29) · theorem pen_eq_hatForm

- [Lean/projects/pen-gauss/FVLT/PenGaussFieldV1.lean](projects/pen-gauss/FVLT/PenGaussFieldV1.lean#L47) · theorem quadPen_eq_phase

- [Lean/projects/pen-gauss/FVLT/PenGaussPrime.lean](projects/pen-gauss/FVLT/PenGaussPrime.lean#L8) · theorem pen_at_one_eq_gaussSum

- [Lean/projects/pen-gauss/FVLT/PenGaussRamanujan.lean](projects/pen-gauss/FVLT/PenGaussRamanujan.lean#L18) · theorem divisorComb_eq_full_comb

- [Lean/projects/pen-gauss/FVLT/PenGaussV1.lean](projects/pen-gauss/FVLT/PenGaussV1.lean#L10) · theorem pen_one_frequency_one

- [Lean/projects/pen-gauss/PenMertensCriterion.lean](projects/pen-gauss/PenMertensCriterion.lean#L16) · theorem sum_pen_frequency_one_eq_M

- [Lean/projects/pen-gauss/StatementCheck.lean](projects/pen-gauss/StatementCheck.lean#L9) · theorem expected

### Gauss joint bridge · Lean 4.33.1 (9)

- [Lean/projects/pen-gauss-joint-433/FourierHelix.lean](projects/pen-gauss-joint-433/FourierHelix.lean#L15) · theorem phase_add

- [Lean/projects/pen-gauss-joint-433/FVLT/PenGaussCore.lean](projects/pen-gauss-joint-433/FVLT/PenGaussCore.lean#L29) · theorem pen_eq_hatForm

- [Lean/projects/pen-gauss-joint-433/FVLT/PenGaussFieldV1.lean](projects/pen-gauss-joint-433/FVLT/PenGaussFieldV1.lean#L47) · theorem quadPen_eq_phase

- [Lean/projects/pen-gauss-joint-433/FVLT/PenGaussPrime.lean](projects/pen-gauss-joint-433/FVLT/PenGaussPrime.lean#L8) · theorem pen_at_one_eq_gaussSum

- [Lean/projects/pen-gauss-joint-433/FVLT/PenGaussRamanujan.lean](projects/pen-gauss-joint-433/FVLT/PenGaussRamanujan.lean#L18) · theorem divisorComb_eq_full_comb

- [Lean/projects/pen-gauss-joint-433/FVLT/PenGaussV1.lean](projects/pen-gauss-joint-433/FVLT/PenGaussV1.lean#L10) · theorem pen_one_frequency_one

- [Lean/projects/pen-gauss-joint-433/JointCompat.lean](projects/pen-gauss-joint-433/JointCompat.lean#L4) · theorem ite_eq_left

- [Lean/projects/pen-gauss-joint-433/PenHatBridge.lean](projects/pen-gauss-joint-433/PenHatBridge.lean#L17) · theorem hat_eq_pen

- [Lean/projects/pen-gauss-joint-433/VariantDirichletProps.lean](projects/pen-gauss-joint-433/VariantDirichletProps.lean#L20) · theorem hat_eq_pen_overlay

### pollard-strassen (2)

- [Lean/projects/pollard-strassen/Axioms.lean](projects/pollard-strassen/Axioms.lean#L5) · #print axioms

- [Lean/projects/pollard-strassen/PollardStrassenNTT.lean](projects/pollard-strassen/PollardStrassenNTT.lean#L34) · theorem powModFuel_eq

### wilson-polygon (3)

- [Lean/projects/wilson-polygon/Audit.lean](projects/wilson-polygon/Audit.lean#L5) · def forbidden

- [Lean/projects/wilson-polygon/StatementPins.lean](projects/wilson-polygon/StatementPins.lean#L12) · theorem mirror_pair

- [Lean/projects/wilson-polygon/WilsonMechanism.lean](projects/wilson-polygon/WilsonMechanism.lean#L18) · theorem vertex_eq_pow

### FF-2 · Atom skin (235)

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data01/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data01/src/FVLTAtomSkinDataV1.lean#L11) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data01/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data01/src/FVLTPillowcaseDataV1.lean#L7) · def translation

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/AuditPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/AuditPillowcaseDataV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/src/FVLTAtomSkinDataV1.lean#L16) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data02/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data03/AuditAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data03/AuditAtomSkinDataV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch01/attempts/Data03/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch01/attempts/Data03/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch01/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch01/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof01/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof02/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof03/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof03/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch02/attempts/Proof03/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch02/attempts/Proof03/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch02/partial_proofs_v0_1/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch03/attempts/Graph01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/attempts/Graph01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch03/attempts/Graph01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/attempts/Graph01/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch03/attempts/Graph02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/attempts/Graph02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch03/attempts/Graph02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/attempts/Graph02/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch03/partial_proofs_v0_2/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch04/attempts/Counts01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/attempts/Counts01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch04/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch04/attempts/Counts02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/attempts/Counts02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch04/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch04/partial_proofs_v0_3/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen01/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen01/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen01/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen01/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen02/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen02/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen02/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen02/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen03/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen03/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen03/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen03/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen04/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen04/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen04/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen04/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen05/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen05/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen05/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen05/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen06/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen06/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/attempts/Pen06/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/attempts/Pen06/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen01/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen01/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen02/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen02/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen03/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen03/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen04/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen04/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen05/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen05/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen06/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen06/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch05/partial_proofs_v0_4/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts03/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts03/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts04/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts04/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen07/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen07/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen07/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen07/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen08/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen08/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen08/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen08/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen09/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen09/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/attempts/Pen09/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/attempts/Pen09/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts03/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts03/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts04/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts04/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen07/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen07/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen07/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen07/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen08/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen08/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen08/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen08/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen09/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen09/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen09/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/evidence/attempts/Pen09/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen01/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen01/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen02/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen02/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen03/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen03/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen04/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen04/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen05/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen05/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen06/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen06/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch06/partial_proofs_v0_5/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow01/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow01/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow01/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow01/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow02/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow02/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow02/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/attempts/Pillow02/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow01/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow01/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow01/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow01/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow02/AuditPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow02/AuditPillowcaseV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow02/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/evidence/attempts/Pillow02/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts01/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts01/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts01/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts02/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts02/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts02/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts03/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts03/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts03/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts04/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts04/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Counts04/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen07/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen07/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen07/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen07/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen08/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen08/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen08/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen08/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen09/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen09/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen09/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/evidence/attempts/Pen09/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen01/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen01/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen01/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen02/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen02/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen02/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen03/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen03/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen03/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen04/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen04/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen04/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen05/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen05/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen05/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen06/AuditSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen06/AuditSkinPenV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/evidence/attempts/Pen06/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/evidence/AuditSkinCountsV1.lean#L2) · #print axioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/inputs/original_freeze/packet/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L6) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L7) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L11) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/predecessor_packet/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinCountsV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinCountsV1.lean#L12) · theorem vertex_count

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinDataV1.lean#L17) · def cyclicDir

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinPenV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTAtomSkinPenV1.lean#L8) · theorem mem_toggle

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTPillowcaseDataV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTPillowcaseDataV1.lean#L15) · def translation

- [FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTPillowcaseV1.lean](../FF/atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/FVLTPillowcaseV1.lean#L7) · theorem pillowRel_equivalence

- [FF/atom_skin_v0_1_20261103/freeze_packet_v0_1/IndependentFVLTReplay435.lean](../FF/atom_skin_v0_1_20261103/freeze_packet_v0_1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/atom_skin_v0_1_20261103/SKELETON_FINAL_AUDIT/SkeletonAuditFF2.lean](../FF/atom_skin_v0_1_20261103/SKELETON_FINAL_AUDIT/SkeletonAuditFF2.lean#L8) · #print axioms

### FF-1 · Farey and Ford contact (319)

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/IndependentFVLTReplay435.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerCompile01/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProducerReplay01/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile01/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofCompile02/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeProofReplay01/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordRationalSmokeV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordRationalSmokeV1.lean#L6) · def checks

- [FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/computable_bridge_v1/snapshots/BridgeSmoke01/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile01/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile01/FVLTFareyContactV1.lean#L10) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile01/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile01/FVLTFordGeometryV1.lean#L18) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile02/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile02/FVLTFareyContactV1.lean#L10) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile02/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile02/FVLTFordGeometryV1.lean#L21) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile03/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile03/FVLTFareyContactV1.lean#L11) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile03/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile03/FVLTFordGeometryV1.lean#L21) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile04/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile04/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile04/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1ACompile04/FVLTFordGeometryV1.lean#L21) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1AReplay01/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1AReplay01/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1AReplay01/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1AReplay01/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile01/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile01/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile01/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile01/FVLTFordGeometryV1.lean#L21) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile02/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile02/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile02/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile02/FVLTFordGeometryV1.lean#L22) · theorem radius_pos

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile03/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile03/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile03/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GCompile03/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GReplay01/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GReplay01/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GReplay01/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/F1_snapshots/F1GReplay01/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile01/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile01/FVLTFareyCertificatesV1.lean#L13) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile02/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile02/FVLTFareyCertificatesV1.lean#L13) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile03/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile03/FVLTFareyCertificatesV1.lean#L13) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile04/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile04/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile05/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile05/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile06/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Compile06/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Replay01/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/F2_snapshots/F2Replay01/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/IndependentFVLTReplay435.lean](../FF/farey_ford_contact_v0_1_20261102/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/farey_ford_contact_v0_1_20261102/library_sync_v0_1/inputs/nucleus/AxiomCheck.lean](../FF/farey_ford_contact_v0_1_20261102/library_sync_v0_1/inputs/nucleus/AxiomCheck.lean#L12) · def standard

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/IndependentFVLTReplay435.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile01/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile01/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile02/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile02/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile03/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile03/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile04/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Compile04/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Replay01/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R1Replay01/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Compile01/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Compile01/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Compile02/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Compile02/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Replay01/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R2Replay01/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile01/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile01/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile02/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile02/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile03/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Compile03/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Replay01/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R3Replay01/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Compile01/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Compile01/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Compile02/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Compile02/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Replay01/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R4Replay01/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Compile01/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Compile01/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Compile02/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Compile02/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Replay01/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_completion_v1/snapshots/R5Replay01/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/IndependentFVLTReplay435.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyArithmeticCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyCertificatesV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyContactV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFareyFixturesCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordExactCoordinatesV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordGeometryV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTFordRationalV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTPhasePartnersV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTStageAIntegrationV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/CompileFVLTUnitFractionSpineV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyArithmeticCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyCertificatesV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyContactV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFareyFixturesCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordExactCoordinatesV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryCompletionV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordGeometryV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTFordRationalV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTPhasePartnersV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/snapshots/ReplayFVLTUnitFractionSpineV1/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyArithmeticCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyCertificatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyContactV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyContactV1.lean#L12) · def det

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyFixturesCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFareyFixturesCompletionV1.lean#L11) · theorem fixture4321_connected

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordExactCoordinatesV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordGeometryCompletionV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordGeometryCompletionV1.lean#L18) · theorem det_nonzero

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordGeometryV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordRationalV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTPhasePartnersV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTPhasePartnersV1.lean#L16) · theorem admissible_two

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTStageAIntegrationV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTStageAIntegrationV1.lean#L6) · #check @FVLT.FareyContactV1.raw_det_one_coprime

- [FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTUnitFractionSpineV1.lean](../FF/farey_ford_contact_v0_1_20261102/stage_a_integration_v1/src/FVLTUnitFractionSpineV1.lean#L17) · theorem unitFrac_coordinates

### FF-4 · Ford to bulb (84)

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Combinatorics01/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/AuditFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/AuditFordBulbDataV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/AuditFVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/AuditFVLTFordBulbDataV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Data01/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/AuditFVLTFordBulbParameterV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/AuditFVLTFordBulbParameterV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/src/FVLTFordBulbParameterV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter01/src/FVLTFordBulbParameterV1.lean#L5) · theorem parameter_fixed_point

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/AuditFVLTFordBulbParameterV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/AuditFVLTFordBulbParameterV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/src/FVLTFordBulbParameterV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch01/attempts/Parameter02/src/FVLTFordBulbParameterV1.lean#L6) · theorem parameter_fixed_point

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics02/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics03/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics04/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch02/attempts/Combinatorics05/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/src/FVLTFordBulbCombinatoricsV1.lean#L5) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics06/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics07/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics08/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch03/attempts/Combinatorics09/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics10/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics11/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch04/attempts/Combinatorics12/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics13/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics14/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics15/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics16/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics17/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch05/attempts/Combinatorics18/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics19/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics20/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/AuditFVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/AuditFVLTFordBulbCombinatoricsV1.lean#L2) · #print axioms

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/src/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/src/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/src/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/batch06/attempts/Combinatorics21/src/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/IndependentFVLTReplay435.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyCertificatesV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyContactV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyContactV1.lean#L12) · def det

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbCombinatoricsV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbCombinatoricsV1.lean#L6) · theorem address_canonical

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbDataV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbDataV1.lean#L19) · def address

- [FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbParameterV1.lean](../FF/ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/FVLTFordBulbParameterV1.lean#L6) · theorem parameter_fixed_point

- [FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/IndependentFVLTReplay435.lean](../FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean](../FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean](../FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean](../FF/ford_to_bulb_v0_1_20261104/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean#L12) · def det

- [FF/ford_to_bulb_v0_1_20261104/SKELETON_FINAL_AUDIT/SkeletonAuditFF4.lean](../FF/ford_to_bulb_v0_1_20261104/SKELETON_FINAL_AUDIT/SkeletonAuditFF4.lean#L6) · #print axioms

### FF-3 · Lifted phasor and Ford map (77)

- [FF/phasor_ford_map_v0_1_20261103/batch01/attempts/Data01/AuditRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch01/attempts/Data01/AuditRosetteFordDataV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch01/attempts/Data01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch01/attempts/Data01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Data02/AuditRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Data02/AuditRosetteFordDataV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Data02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Data02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/AuditRosetteFordEndpointsV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/AuditRosetteFordEndpointsV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/src/FVLTRosetteFordEndpointsV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints01/src/FVLTRosetteFordEndpointsV1.lean#L6) · theorem det_zero_iff_address_equal

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/AuditRosetteFordEndpointsV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/AuditRosetteFordEndpointsV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/src/FVLTRosetteFordEndpointsV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch02/attempts/Endpoints02/src/FVLTRosetteFordEndpointsV1.lean#L6) · theorem det_zero_iff_address_equal

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/AuditRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/AuditRosetteFordPhaseV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase01/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/AuditRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/AuditRosetteFordPhaseV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch03/attempts/Phase02/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/AuditRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/AuditRosetteFordArithmeticV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/src/FVLTRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/src/FVLTRosetteFordArithmeticV1.lean#L6) · theorem integer_address_iff

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/AuditRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/AuditRosetteFordArithmeticV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/src/FVLTRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/src/FVLTRosetteFordArithmeticV1.lean#L6) · theorem integer_address_iff

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/AuditRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/AuditRosetteFordArithmeticV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/src/FVLTRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/src/FVLTRosetteFordArithmeticV1.lean#L6) · theorem integer_address_iff

- [FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch04/attempts/Arithmetic03/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep01/src/FVLTRosetteFordSweepV1.lean#L6) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep02/src/FVLTRosetteFordSweepV1.lean#L6) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep03/src/FVLTRosetteFordSweepV1.lean#L6) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch05/attempts/Sweep04/src/FVLTRosetteFordSweepV1.lean#L6) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final01/src/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final02/src/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final03/src/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/AuditRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/AuditRosetteFordSweepV1.lean#L2) · #print axioms

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/batch06/attempts/Final04/src/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/IndependentFVLTReplay435.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean#L12) · def det

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordExactCoordinatesV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordGeometryV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordRationalV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/controls/freeze_packet_v0_1/inputs/library_sources/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordArithmeticV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordArithmeticV1.lean#L6) · theorem integer_address_iff

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordDataV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordDataV1.lean#L21) · def fordAddress

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordEndpointsV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordEndpointsV1.lean#L6) · theorem det_zero_iff_address_equal

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordPhaseV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordPhaseV1.lean#L6) · theorem phasor_real_iff

- [FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordSweepV1.lean](../FF/phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/FVLTRosetteFordSweepV1.lean#L7) · theorem shell_contact_parameterization

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/IndependentFVLTReplay435.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/IndependentFVLTReplay435.lean#L18) · def allowedAxioms

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean#L17) · theorem coprime_from_det

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean#L15) · theorem fareyAdj_symm

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean#L12) · def det

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordExactCoordinatesV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordExactCoordinatesV1.lean#L11) · theorem kissNQ_eq

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordGeometryV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordGeometryV1.lean#L22) · theorem centre_re

- [FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordRationalV1.lean](../FF/phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/inputs/library_sources/FVLTFordRationalV1.lean#L7) · def radiusQ

- [FF/phasor_ford_map_v0_1_20261103/SKELETON_FINAL_AUDIT/SkeletonAuditFF3.lean](../FF/phasor_ford_map_v0_1_20261103/SKELETON_FINAL_AUDIT/SkeletonAuditFF3.lean#L8) · #print axioms
