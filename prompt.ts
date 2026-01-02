// Content is user-generated and unverified.
// # ==============================================================================
// # ANALYTICAL PROMPTS FOR HRQoL EQ-5D VALUE SET THEMATIC ANALYSIS
// # ==============================================================================
// # Purpose: Guided prompts for extracting thematic information from expert
// #          interviews on health-related quality of life value set development
// # Use with: hrqol_thematic_coding_framework.R
// # ==============================================================================

// analytical_prompts <- list(

//   # ==========================================================================
//   # THEME 1: CONTEXT AND RATIONALE FOR VALUE SET DEVELOPMENT
//   # ==========================================================================

//   theme_1_context_rationale = list(
//     theme_name = "Context and Rationale",
//     theme_id = "T1",

//     prompts = list(

//       # Sub-theme 1.1: Policy Drivers
//       policy_drivers = c(
//         "What policy requirements or mandates drove the decision to develop a country-specific value set?",
//         "Were there specific HTA (Health Technology Assessment) requirements that necessitated local value sets?",
//         "How did insurance companies or payers influence the decision to develop value sets?",
//         "What role did international donors or development partners play in initiating this work?",
//         "Were there any governmental health reform initiatives that created demand for value sets?"
//       ),

//       # Sub-theme 1.2: Value Proposition
//       value_proposition = c(
//         "What specific advantages does having a country-specific value set provide?",
//         "How do local cultural or health beliefs differ in ways that justify a new value set?",
//         "What evidence suggests that foreign value sets would not adequately represent local preferences?",
//         "How might these lessons about country-specific value sets apply to South Africa's diverse population?",
//         "What policy or clinical decisions become possible with country-specific value sets?"
//       ),

//       # Sub-theme 1.3: Foreign Value Set Consideration
//       foreign_value_sets = c(
//         "Which foreign or regional value sets were considered as alternatives?",
//         "What were the specific reasons for not adopting an existing value set?",
//         "Were there any pilot studies comparing foreign value sets to preliminary local data?",
//         "How similar or different is the population to countries with existing value sets?",
//         "What adaptation approaches were considered before deciding on de novo development?"
//       ),

//       # Sub-theme 1.4: Funding Model
//       funding_model = c(
//         "What was the total budget for the value set development study?",
//         "Which organizations or entities provided funding?",
//         "Were there specific budget line items (e.g., personnel, training, data collection)?",
//         "Did the funding cover all project costs including training and capacity building?",
//         "How was the funding secured and what was the process timeline?",
//         "Were there any co-funding arrangements or in-kind contributions?",
//         "What advice would you give about budgeting for similar work in South Africa?"
//       )
//     ),

//     extraction_instructions = "Look for explicit mentions of why the study was undertaken, who initiated it, what alternatives were considered, and how it was funded. Pay attention to policy context, stakeholder motivations, and financial arrangements."
//   ),

//   # ==========================================================================
//   # THEME 2: METHODOLOGICAL APPROACHES AND ADAPTATIONS
//   # ==========================================================================

//   theme_2_methodology = list(
//     theme_name = "Methodological Approaches",
//     theme_id = "T2",

//     prompts = list(

//       # Sub-theme 2.1: Valuation Methods
//       valuation_methods = c(
//         "Which valuation method(s) were used: composite time trade-off (cTTO), discrete choice experiment (DCE), or hybrid?",
//         "What was the sample size for each valuation method?",
//         "Why was this particular methodological approach chosen?",
//         "Were there any methodological innovations or modifications to standard protocols?",
//         "How were health states selected for valuation?",
//         "What statistical models were used for analysis (e.g., Tobit, GLM, mixed models)?"
//       ),

//       # Sub-theme 2.2: Study Progress
//       study_progress = c(
//         "What is the current status of the valuation study (planning, data collection, analysis, completed)?",
//         "Which phases have been completed and which are ongoing?",
//         "What is the expected timeline for completion?",
//         "Have there been any delays or accelerations in the planned timeline?",
//         "What milestones have been achieved to date?"
//       ),

//       # Sub-theme 2.3: Anticipated vs. Actual Challenges
//       challenges = c(
//         "What challenges were anticipated during the planning phase?",
//         "Which anticipated challenges actually materialized?",
//         "What unexpected challenges emerged during implementation?",
//         "How were challenges addressed or resolved?",
//         "Were there any challenges that could not be fully resolved?",
//         "What would you do differently knowing what you know now?"
//       ),

//       # Sub-theme 2.4: Protocol Adaptations
//       protocol_adaptations = c(
//         "How were the EuroQol protocols adapted for the local context?",
//         "What translation methods were used for the valuation tasks?",
//         "Were back-translations performed and by whom?",
//         "How were health state descriptions culturally adapted?",
//         "Were visual aids or other materials modified?",
//         "What cognitive testing or piloting was done on adapted materials?"
//       ),

//       # Sub-theme 2.5: Worse Than Death States
//       worse_than_death = c(
//         "Were health states worse than death included in the valuation?",
//         "Were there ethical concerns about asking people to value states worse than death?",
//         "How culturally acceptable was the concept of 'worse than death' in your setting?",
//         "Was the methodology piloted specifically to test acceptability of worse than death states?",
//         "Were any cultural or religious barriers identified?",
//         "How were interviewers trained to handle sensitive worse than death valuations?",
//         "What proportion of respondents provided worse than death valuations?"
//       ),

//       # Sub-theme 2.6: Recommendations for South Africa
//       sa_recommendations = c(
//         "Based on your methodological experience, what would you specifically recommend for South Africa?",
//         "Are there methodological approaches that worked particularly well?",
//         "What methodological decisions would you advise South Africa to avoid?",
//         "How should South Africa balance methodological rigor with practical feasibility?",
//         "What are the most critical methodological decisions South Africa should prioritize?"
//       )
//     ),

//     extraction_instructions = "Extract specific methodological choices, sample sizes, analytical approaches, and adaptation strategies. Note both planned and actual implementation approaches. Pay special attention to cultural adaptations and ethical considerations."
//   ),

//   # ==========================================================================
//   # THEME 3: POPULATION REPRESENTATION AND SAMPLING
//   # ==========================================================================

//   theme_3_population = list(
//     theme_name = "Population Representation",
//     theme_id = "T3",

//     prompts = list(

//       # Sub-theme 3.1: National Representativeness
//       representativeness = c(
//         "What sampling strategy was used to achieve national representativeness?",
//         "How were geographic regions selected and weighted?",
//         "How were different socioeconomic strata included?",
//         "What was the rural-urban distribution in the sample?",
//         "How were linguistic or ethnic groups represented?",
//         "Were sampling quotas used, and if so, for which characteristics?",
//         "How was the sampling frame developed?"
//       ),

//       # Sub-theme 3.2: Recruitment Strategies
//       recruitment = c(
//         "What recruitment strategies were most successful?",
//         "How were participants from underserved communities recruited?",
//         "What approaches worked for recruiting in remote or rural areas?",
//         "What incentives were provided to participants?",
//         "What was the response rate and how does it compare to expectations?",
//         "Were there specific retention strategies to reduce dropout?",
//         "What community engagement approaches facilitated recruitment?"
//       ),

//       # Sub-theme 3.3: Balancing Representation
//       balancing_representation = c(
//         "What difficulties arose in balancing representation across age groups?",
//         "Were there gender imbalances and how were they addressed?",
//         "How was disease profile or health status representation handled?",
//         "Was there adequate representation of insured vs. uninsured populations?",
//         "What compromises had to be made in achieving representative sampling?",
//         "Were there any groups that were particularly difficult to recruit?",
//         "How were these representation challenges overcome?"
//       ),

//       # Sub-theme 3.4: South Africa Inclusivity Lessons
//       sa_inclusivity = c(
//         "What specific lessons about population diversity could apply to South Africa?",
//         "How should South Africa approach sampling given its 11 official languages?",
//         "What strategies would ensure representation across South Africa's diverse racial and ethnic groups?",
//         "How can South Africa balance urban-rural representation given its population distribution?",
//         "What considerations are important for including historically disadvantaged populations?"
//       )
//     ),

//     extraction_instructions = "Focus on concrete sampling strategies, achieved sample characteristics, recruitment successes and challenges, and specific recommendations for diverse populations. Extract actual numbers and proportions where mentioned."
//   ),

//   # ==========================================================================
//   # THEME 4: IMPLEMENTATION AND FEASIBILITY
//   # ==========================================================================

//   theme_4_implementation = list(
//     theme_name = "Implementation and Feasibility",
//     theme_id = "T4",

//     prompts = list(

//       # Sub-theme 4.1: Resource Requirements
//       resources = c(
//         "What were the major funding requirements for the study?",
//         "How many staff/personnel were needed at each project phase?",
//         "What infrastructure was required (office space, equipment, vehicles)?",
//         "What were the major cost categories (personnel, materials, travel, data collection)?",
//         "Were there unexpected resource needs that emerged?",
//         "How adequate was the initial resource allocation?"
//       ),

//       # Sub-theme 4.2: Capacity Building
//       capacity = c(
//         "What local capacity existed at the start of the project?",
//         "How was local expertise in study design developed or leveraged?",
//         "What data collection capacity needed to be built?",
//         "What analytical skills were developed during the project?",
//         "Were local researchers involved in all phases?",
//         "How sustainable is the capacity that was built?"
//       ),

//       # Sub-theme 4.3: Partnerships
//       partnerships = c(
//         "Which academic institutions were partners and what was their role?",
//         "How was the Ministry of Health involved?",
//         "What role did regulatory bodies play?",
//         "How did EuroQol support the project?",
//         "Were there partnerships with international organizations like WHO?",
//         "Which partnerships were most valuable and why?",
//         "What advice would you give about partnership development?"
//       ),

//       # Sub-theme 4.4: Practical Barriers and Solutions
//       barriers = c(
//         "What logistical challenges were encountered?",
//         "Were there issues with participant acceptability of the methods?",
//         "What language barriers emerged and how were they addressed?",
//         "How were practical barriers resolved?",
//         "What creative solutions were developed?",
//         "What barriers remain unresolved?"
//       ),

//       # Sub-theme 4.5: Advance Planning
//       advance_planning = c(
//         "What issues should South Africa anticipate and plan for?",
//         "What preparatory work is most important?",
//         "What risk mitigation strategies would you recommend?",
//         "How much lead time is needed for different project components?",
//         "What early decisions have the biggest downstream impact?"
//       ),

//       # Sub-theme 4.6: Informed Consent and Inclusion
//       consent_inclusion = c(
//         "What informed consent process was used?",
//         "How were consent forms adapted for different literacy levels?",
//         "Were people with mental health conditions included?",
//         "Were people with disabilities included in the sample?",
//         "What accommodations were made for vulnerable populations?",
//         "What ethical approval processes were required?"
//       ),

//       # Sub-theme 4.7: Training
//       training = c(
//         "What training was required for field staff?",
//         "How long was the interviewer training?",
//         "What qualifications did trainers need?",
//         "What was covered in the training curriculum?",
//         "How was quality control integrated into training?",
//         "Were refresher trainings conducted?",
//         "What training materials or SOPs were developed?"
//       ),

//       # Sub-theme 4.8: Quality Control
//       quality_control = c(
//         "What quality control processes were implemented?",
//         "How was data quality monitored during collection?",
//         "What supervision structures were in place?",
//         "What quality assurance protocols were followed?",
//         "How were problems identified and addressed in real-time?",
//         "What validation procedures were used?"
//       ),

//       # Sub-theme 4.9: Data Collection Details
//       data_collection = c(
//         "How long was the data collection period?",
//         "How many field staff were employed?",
//         "Can you describe the organizational structure (organigramme)?",
//         "Was data collection digital (tablets) or paper-based?",
//         "What data collection software or tools were used?",
//         "What field challenges arose during data collection?",
//         "How were data security and confidentiality maintained?"
//       ),

//       # Sub-theme 4.10: Analysis and Dissemination
//       analysis_dissemination = c(
//         "Which organization conducts the analysis?",
//         "Is EuroQol involved in the analysis?",
//         "What journals are being targeted for publication?",
//         "What is the dissemination strategy?",
//         "When are results expected to be published?",
//         "How will results be communicated to stakeholders?"
//       )
//     ),

//     extraction_instructions = "Extract operational details, numbers of staff, timelines, costs, training approaches, quality control measures, and practical implementation details. Look for specific resource requirements, partnership structures, and lessons about what works in practice."
//   ),

//   # ==========================================================================
//   # THEME 5: POLICY INTEGRATION AND REGULATORY ENGAGEMENT
//   # ==========================================================================

//   theme_5_policy = list(
//     theme_name = "Policy Integration and Regulation",
//     theme_id = "T5",

//     prompts = list(

//       # Sub-theme 5.1: Stakeholder Engagement in Methodology
//       stakeholder_engagement = c(
//         "Which regulatory bodies were engaged in the methodology design?",
//         "How did stakeholder input shape the study methods?",
//         "Was early engagement helpful in ensuring result acceptability?",
//         "What stakeholder buy-in strategies were most effective?",
//         "When in the process should stakeholder engagement begin?"
//       ),

//       # Sub-theme 5.2: Stakeholder Inclusion on Study Team
//       team_inclusion = c(
//         "Were stakeholders included on the study team?",
//         "What was the governance structure of the project?",
//         "How were conflicts of interest managed?",
//         "What benefits came from collaborative design?",
//         "Would you recommend this approach and why?"
//       ),

//       # Sub-theme 5.3: Integration Plans
//       integration_plans = c(
//         "What are the plans for integrating value sets into HTA processes?",
//         "How will value sets be incorporated into benefit package design?",
//         "Will insurance companies use these value sets for decision-making?",
//         "What is the policy adoption strategy?",
//         "What is the implementation roadmap?",
//         "Are there legal or regulatory requirements for using the value sets?"
//       ),

//       # Sub-theme 5.4: Regulatory Endorsement
//       regulatory_endorsement = c(
//         "What role are regulatory bodies playing in endorsing the value sets?",
//         "Is there official government backing or recognition?",
//         "How is legitimacy being established?",
//         "What official approval processes are required?",
//         "How important is regulatory endorsement for uptake?"
//       ),

//       # Sub-theme 5.5: Adoption Challenges
//       adoption_challenges = c(
//         "What barriers to policy uptake are anticipated?",
//         "Is there stakeholder resistance to using the new value sets?",
//         "What challenges exist in securing consistent use?",
//         "How will sustainability of value set use be ensured?",
//         "What strategies address adoption challenges?"
//       )
//     ),

//     extraction_instructions = "Focus on stakeholder engagement strategies, governance structures, plans for policy integration, regulatory processes, and challenges in achieving adoption. Look for specific examples of stakeholder involvement and policy pathways."
//   ),

//   # ==========================================================================
//   # THEME 6: ETHICAL, CULTURAL, AND EQUITY CONSIDERATIONS
//   # ==========================================================================

//   theme_6_ethical_cultural = list(
//     theme_name = "Ethical, Cultural, and Equity Considerations",
//     theme_id = "T6",

//     prompts = list(

//       # Sub-theme 6.1: Cultural Sensitivities
//       cultural_sensitivities = c(
//         "How were cultural sensitivities around mental health addressed?",
//         "What disability-related sensitivities needed consideration?",
//         "Were there stigma issues in health state descriptions?",
//         "How were health states made culturally appropriate?",
//         "What cultural consultation processes were used?",
//         "Were there topics or health states that were culturally taboo?"
//       ),

//       # Sub-theme 6.2: Public/Patient Involvement
//       public_involvement = c(
//         "Were public or patient representatives on the study team?",
//         "How was community engagement structured?",
//         "What participatory approaches were used?",
//         "How did public involvement influence the study?",
//         "Would you recommend this approach for South Africa?"
//       ),

//       # Sub-theme 6.3: Vulnerable Populations
//       vulnerable_populations = c(
//         "How were vulnerable populations represented?",
//         "Were high disease burden populations specifically included?",
//         "How were marginalized groups engaged?",
//         "What equity considerations shaped sampling?",
//         "Were there special accommodations for vulnerable groups?"
//       ),

//       # Sub-theme 6.4: Equity and Fairness
//       equity_fairness = c(
//         "How was equity in preference capture ensured?",
//         "Were there concerns about fairness across sub-populations?",
//         "How was inclusive representation achieved?",
//         "What principles of distributive justice were considered?",
//         "How do you balance representativeness with equity?"
//       ),

//       # Sub-theme 6.5: Social Legitimacy
//       social_legitimacy = c(
//         "How was social acceptability of the study established?",
//         "What legitimacy-building strategies were used?",
//         "How was trust developed with communities?",
//         "What makes a value set socially legitimate?",
//         "How important is perceived fairness for uptake?"
//       )
//     ),

//     extraction_instructions = "Extract discussions of cultural adaptation, ethical considerations, inclusion of vulnerable or marginalized groups, equity approaches, and strategies for building social legitimacy. Pay attention to tensions between methodological requirements and cultural appropriateness."
//   ),

//   # ==========================================================================
//   # THEME 7: LESSONS LEARNED AND BEST PRACTICES
//   # ==========================================================================

//   theme_7_lessons = list(
//     theme_name = "Lessons Learned and Best Practices",
//     theme_id = "T7",

//     prompts = list(

//       # Sub-theme 7.1: Successes
//       successes = c(
//         "What were the biggest successes of the valuation study?",
//         "What worked particularly well?",
//         "What positive outcomes were achieved?",
//         "What successful strategies can be replicated?",
//         "What achievements are you most proud of?"
//       ),

//       # Sub-theme 7.2: Pitfalls to Avoid
//       pitfalls = c(
//         "What mistakes were made that others should avoid?",
//         "What challenges could have been prevented with better planning?",
//         "What would you advise South Africa not to do?",
//         "What lessons were learned from failures or setbacks?",
//         "What are the cautionary tales from your experience?"
//       ),

//       # Sub-theme 7.3: Replicable Practices
//       replicable_practices = c(
//         "What interviewer training protocols can be shared?",
//         "Are there translation protocols that could be adapted?",
//         "What stakeholder engagement practices worked well?",
//         "What SOPs or manuals will be made available?",
//         "What materials or resources can South Africa use?",
//         "Which specific practices should South Africa replicate?"
//       ),

//       # Sub-theme 7.4: Transferability
//       transferability = c(
//         "What similarities exist between your country and South Africa?",
//         "What key differences should South Africa consider?",
//         "How applicable are your lessons to the South African context?",
//         "What adaptations would be needed for South Africa?",
//         "What lessons transfer well across contexts and which don't?"
//       )
//     ),

//     extraction_instructions = "Focus on explicit lessons learned, both positive and negative. Extract specific practices that worked or failed, and expert assessments of what is transferable versus context-specific. Look for concrete advice and recommendations."
//   ),

//   # ==========================================================================
//   # THEME 8: EXPERT RECOMMENDATIONS AND FUTURE DIRECTIONS
//   # ==========================================================================

//   theme_8_recommendations = list(
//     theme_name = "Expert Recommendations and Future Directions",
//     theme_id = "T8",

//     prompts = list(

//       # Sub-theme 8.1: Top Recommendations
//       top_recommendations = c(
//         "If advising South Africa, what are your top three recommendations?",
//         "What is most critical for developing a credible value set?",
//         "What ensures policy relevance of value sets?",
//         "What are the key success factors?",
//         "What advice is most important for South Africa to heed?"
//       ),

//       # Sub-theme 8.2: Short-term Priorities
//       short_term_actions = c(
//         "What governance structures should be established first?",
//         "Which partnerships should South Africa prioritize developing?",
//         "Should South Africa conduct pilot testing before full study?",
//         "What immediate actions would have the biggest impact?",
//         "What foundation-building activities are most important?",
//         "What can be done in the first 6-12 months?"
//       ),

//       # Sub-theme 8.3: Long-term Strategies
//       long_term_strategies = c(
//         "How should value sets be embedded in South Africa's National Health Insurance (NHI)?",
//         "What strategies ensure integration into universal health coverage?",
//         "How often should value sets be updated?",
//         "What long-term sustainability strategies are important?",
//         "How can value sets become institutionalized in health policy?",
//         "What 5-10 year vision would you recommend?"
//       ),

//       # Sub-theme 8.4: LMIC Collaboration
//       lmic_collaboration = c(
//         "What collaboration opportunities exist between your country and South Africa?",
//         "How can shared learning between LMICs be facilitated?",
//         "What LMIC networks or platforms exist for knowledge exchange?",
//         "What value is there in South-South cooperation?",
//         "How can LMIC countries support each other in this work?",
//         "What collaborative research could be valuable?"
//       )
//     ),

//     extraction_instructions = "Extract concrete, actionable recommendations. Distinguish between short-term tactical advice and long-term strategic guidance. Pay attention to prioritization and sequencing of recommendations. Note collaboration opportunities and network-building suggestions."
//   )
// )

// # ==============================================================================
// # CROSS-CUTTING ANALYTICAL QUESTIONS
// # ==============================================================================

// cross_cutting_prompts <- list(

//   comparative_analysis = c(
//     "How does the expert compare their country's experience to South Africa's context?",
//     "What explicit comparisons are made between countries?",
//     "What similarities does the expert note?",
//     "What differences does the expert highlight?",
//     "What context-specific factors does the expert identify?"
//   ),

//   temporal_framing = c(
//     "Is the expert discussing planning, implementation, or post-study experiences?",
//     "What references to specific timeframes or phases are made?",
//     "Are discussions retrospective (lessons learned) or prospective (plans)?",
//     "What timeline information is provided?"
//   ),

//   evidence_quality = c(
//     "Is this a definitive statement based on experience or a tentative suggestion?",
//     "Is the recommendation conditional on certain circumstances?",
//     "What level of certainty does the expert express?",
//     "Is this evidence-based or experiential knowledge?",
//     "How strong is the expert's recommendation?"
//   ),

//   lmic_specificity = c(
//     "Is this advice specific to low- and middle-income countries?",
//     "Are resource constraints explicitly mentioned?",
//     "Are there capacity limitations discussed?",
//     "How relevant is this to Global South contexts?",
//     "What makes this particular to low-resource settings?"
//   ),

//   practical_vs_conceptual = c(
//     "Is this operational, hands-on guidance?",
//     "Is this practical implementation advice?",
//     "Is this a theoretical or conceptual discussion?",
//     "Is this about frameworks versus actual practice?",
//     "How actionable is this information?"
//   ),

//   quantitative_information = c(
//     "What specific numbers are mentioned (costs, sample sizes, durations)?",
//     "What metrics or measurements are provided?",
//     "What timeframes are specified?",
//     "What percentages or proportions are given?",
//     "What concrete quantities provide context?"
//   )
// )

// # ==============================================================================
// # USAGE INSTRUCTIONS
// # ==============================================================================

// usage_instructions <- "
// USING THESE ANALYTICAL PROMPTS:

// 1. PREPARATION
//    - Review all prompts for the relevant theme before reading the transcript
//    - Familiarize yourself with the codes in the coding framework (hrqol_thematic_coding_framework.R)
//    - Have both the prompts and coding framework open during analysis

// 2. READING THE TRANSCRIPT
//    - Read through the transcript once without coding
//    - On second reading, use prompts to identify relevant segments
//    - Mark segments that respond to multiple prompts
//    - Note unexpected themes not captured by prompts

// 3. APPLYING CODES
//    - Use prompts to identify which codes apply to each segment
//    - One segment can have multiple codes
//    - Record both explicit statements and implicit meanings
//    - Write memos about interpretation and context

// 4. CROSS-CUTTING ANALYSIS
//    - After thematic coding, apply cross-cutting analytical questions
//    - Assess evidence quality, temporal framing, LMIC-specificity for each theme
//    - Note comparative statements and quantitative mentions

// 5. SYNTHESIS
//    - For each theme, summarize what the expert said
//    - Extract representative quotes for each sub-theme
//    - Identify unique insights or unexpected findings
//    - Note contradictions or tensions in the data

// 6. ITERATION
//    - Coding is iterative - review and refine codes
//    - Some prompts may not be relevant for all interviews
//    - New codes may emerge from the data
//    - Update the framework as needed for South African context

// 7. QUALITY CHECKS
//    - Are you capturing the expert's actual meaning?
//    - Are you over-coding (too many codes per segment)?
//    - Are you under-coding (missing important content)?
//    - Have you captured both successes and challenges?
//    - Have you noted methodological details and numbers?
// "

// # Export prompts to a readable format
// if (interactive()) {
//   cat(usage_instructions)
//   cat("\n\nPrompt framework loaded successfully.\n")
//   cat("Access prompts using: analytical_prompts$theme_X_name$prompts\n")
// }

// # ==============================================================================
// # END OF ANALYTICAL PROMPTS
// # ==============================================================================
