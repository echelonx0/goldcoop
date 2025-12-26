// lib/core/constants/legal_content.dart
// Legal content constants - Terms & Conditions, Privacy Policy

/// Legal content for the Gold Savings app
class LegalContent {
  LegalContent._();

  // ==================== META INFO ====================

  static const String companyName = 'GOLD Savings & Investment Co-operative';
  static const String websiteUrl = 'goldcoop.com.ng';
  static const String termsUrl = 'https://goldcoop.com.ng/terms';
  static const String privacyUrl = 'https://goldcoop.com.ng/privacy';

  // ==================== TERMS & CONDITIONS ====================

  static final DateTime termsEffectiveDate = DateTime(2024, 12, 1);
  static final DateTime termsLastUpdated = DateTime(2024, 12, 15);

  static const String termsTitle = 'Terms & Conditions';

  static const List<LegalSection> termsSections = [
    LegalSection(
      title: '1. Acceptance of Terms',
      content: '''
By accessing or using the GOLD Savings & Investment Co-operative mobile application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.

These terms constitute a legally binding agreement between you and GOLD Savings & Investment Co-operative regarding your use of our savings and investment platform.
''',
    ),
    LegalSection(
      title: '2. Eligibility',
      content: '''
To use our services, you must:
• Be at least 18 years of age
• Be a legal resident of Nigeria or an eligible jurisdiction
• Provide accurate and complete registration information
• Complete our Know Your Customer (KYC) verification process
• Have the legal capacity to enter into binding contracts

We reserve the right to refuse service, terminate accounts, or cancel transactions at our sole discretion if we believe you do not meet these eligibility requirements.
''',
    ),
    LegalSection(
      title: '3. Account Registration & Security',
      content: '''
You are responsible for maintaining the confidentiality of your account credentials, including your password and any other security information. You agree to:

• Notify us immediately of any unauthorized access to your account
• Use strong, unique passwords and enable two-factor authentication when available
• Not share your account credentials with any third party
• Keep your registered phone number and email address current

We are not liable for any loss or damage arising from your failure to comply with these security obligations.
''',
    ),
    LegalSection(
      title: '4. Savings & Investment Services',
      content: '''
Our platform offers various savings and investment products. By using these services, you acknowledge that:

• All investments carry risk, including the potential loss of principal
• Past performance does not guarantee future results
• Interest rates and returns may vary and are subject to change
• Minimum balance requirements may apply to certain accounts
• Early withdrawal penalties may apply to fixed-term investments

We will provide clear information about each product's terms, risks, and potential returns before you commit your funds.
''',
    ),
    LegalSection(
      title: '5. Deposits & Withdrawals',
      content: '''
Deposits:
• Deposits may be made through approved payment methods
• Funds are credited upon confirmation from the payment processor
• We reserve the right to hold deposits pending verification

Withdrawals:
• Withdrawal requests are processed within 1-3 business days
• Withdrawals are sent to verified bank accounts only
• Daily and monthly withdrawal limits may apply
• Additional verification may be required for large withdrawals
''',
    ),
    LegalSection(
      title: '6. Fees & Charges',
      content: '''
We strive to maintain transparent and competitive pricing. Applicable fees include:

• Account maintenance fees (if applicable)
• Transaction processing fees
• Early withdrawal penalties for fixed-term products
• Wire transfer fees for international transactions

A complete fee schedule is available within the App and on our website. We will notify you of any fee changes at least 30 days in advance.
''',
    ),
    LegalSection(
      title: '7. Prohibited Activities',
      content: '''
You agree not to use our services for:

• Money laundering or terrorist financing
• Fraudulent or illegal activities
• Circumventing our security measures
• Interfering with the proper functioning of the App
• Violating any applicable laws or regulations
• Creating multiple accounts without authorization
• Engaging in any activity that harms other users

Violation of these prohibitions may result in immediate account termination and reporting to relevant authorities.
''',
    ),
    LegalSection(
      title: '8. Privacy & Data Protection',
      content: '''
Your privacy is important to us. Our collection, use, and protection of your personal information is governed by our Privacy Policy, which is incorporated into these Terms by reference.

We comply with the Nigeria Data Protection Regulation (NDPR) and other applicable data protection laws.
''',
    ),
    LegalSection(
      title: '9. Limitation of Liability',
      content: '''
To the maximum extent permitted by law:

• We are not liable for any indirect, incidental, or consequential damages
• Our total liability shall not exceed the fees paid by you in the 12 months preceding the claim
• We are not responsible for losses due to events beyond our reasonable control
• We do not guarantee uninterrupted access to our services

This limitation applies regardless of the form of action, whether in contract, tort, or otherwise.
''',
    ),
    LegalSection(
      title: '10. Dispute Resolution',
      content: '''
Any disputes arising from these Terms shall be resolved as follows:

1. Informal Resolution: Contact our support team to attempt resolution
2. Mediation: If informal resolution fails, parties agree to mediation
3. Arbitration: Disputes not resolved through mediation shall be submitted to binding arbitration in Lagos, Nigeria

You agree to waive any right to participate in class action lawsuits against us.
''',
    ),
    LegalSection(
      title: '11. Modifications to Terms',
      content: '''
We reserve the right to modify these Terms at any time. Changes will be effective upon posting to the App or our website. We will notify you of material changes via email or in-app notification.

Your continued use of our services after changes are posted constitutes acceptance of the modified Terms.
''',
    ),
    LegalSection(
      title: '12. Contact Information',
      content: '''
For questions about these Terms, please contact us:

GOLD Savings & Investment Co-operative
Email: support@goldcoop.com.ng
Website: www.goldcoop.com.ng
Phone: +234 XXX XXX XXXX

Our support team is available Monday through Friday, 9:00 AM to 5:00 PM WAT.
''',
    ),
  ];

  // ==================== PRIVACY POLICY ====================

  static final DateTime privacyEffectiveDate = DateTime(2024, 12, 1);
  static final DateTime privacyLastUpdated = DateTime(2024, 12, 15);

  static const String privacyTitle = 'Privacy Policy';

  static const List<LegalSection> privacySections = [
    LegalSection(
      title: '1. Introduction',
      content: '''
GOLD Savings & Investment Co-operative ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.

We comply with the Nigeria Data Protection Regulation (NDPR) and applicable international data protection standards.
''',
    ),
    LegalSection(
      title: '2. Information We Collect',
      content: '''
Personal Information:
• Full name and contact details (email, phone number, address)
• Date of birth and government-issued ID numbers
• Bank Verification Number (BVN) and bank account details
• Photographs for identity verification
• Employment and income information

Technical Information:
• Device identifiers and IP addresses
• App usage data and interaction patterns
• Location data (with your consent)
• Push notification tokens
''',
    ),
    LegalSection(
      title: '3. How We Use Your Information',
      content: '''
We use your information to:

• Create and manage your account
• Process transactions and provide our services
• Verify your identity and prevent fraud
• Comply with legal and regulatory requirements
• Send you important account notifications
• Improve our products and services
• Provide customer support
• Send marketing communications (with your consent)

We will not use your information for purposes incompatible with those stated above without your consent.
''',
    ),
    LegalSection(
      title: '4. Information Sharing',
      content: '''
We may share your information with:

• Financial institutions for transaction processing
• Identity verification service providers
• Regulatory authorities as required by law
• Professional advisors (legal, accounting, auditing)
• Service providers who assist our operations

We do not sell your personal information to third parties. All third parties are contractually bound to protect your data.
''',
    ),
    LegalSection(
      title: '5. Data Security',
      content: '''
We implement robust security measures to protect your data:

• End-to-end encryption for data transmission
• Secure data centers with restricted access
• Regular security audits and penetration testing
• Employee training on data protection
• Multi-factor authentication options
• Automatic session timeouts

Despite our efforts, no method of transmission over the internet is 100% secure. We cannot guarantee absolute security.
''',
    ),
    LegalSection(
      title: '6. Data Retention',
      content: '''
We retain your personal information for as long as necessary to:

• Maintain your account and provide services
• Comply with legal and regulatory requirements
• Resolve disputes and enforce agreements
• Meet our business and audit requirements

After account closure, we may retain certain information for up to 7 years as required by financial regulations.
''',
    ),
    LegalSection(
      title: '7. Your Rights',
      content: '''
Under the NDPR and applicable laws, you have the right to:

• Access your personal information we hold
• Correct inaccurate or incomplete data
• Request deletion of your data (subject to legal requirements)
• Object to certain processing activities
• Withdraw consent for optional processing
• Request data portability
• Lodge complaints with the regulatory authority

To exercise these rights, contact us at privacy@goldcoop.com.ng
''',
    ),
    LegalSection(
      title: '8. Cookies & Tracking',
      content: '''
Our App and website may use cookies and similar technologies to:

• Remember your preferences and settings
• Analyze App usage and performance
• Provide personalized experiences
• Enable security features

You can manage cookie preferences through your device settings. Disabling certain cookies may affect App functionality.
''',
    ),
    LegalSection(
      title: '9. Third-Party Links',
      content: '''
Our App may contain links to third-party websites or services. We are not responsible for the privacy practices of these external sites.

We encourage you to review the privacy policies of any third-party services before providing your information.
''',
    ),
    LegalSection(
      title: '10. Children\'s Privacy',
      content: '''
Our services are not intended for individuals under 18 years of age. We do not knowingly collect personal information from children.

If we become aware that we have collected data from a child without parental consent, we will take steps to delete that information promptly.
''',
    ),
    LegalSection(
      title: '11. International Data Transfers',
      content: '''
Your information may be transferred to and processed in countries other than Nigeria. When we transfer data internationally, we ensure appropriate safeguards are in place:

• Standard contractual clauses
• Adequacy decisions where applicable
• Certification mechanisms

We will always ensure your data receives equivalent protection regardless of location.
''',
    ),
    LegalSection(
      title: '12. Changes to This Policy',
      content: '''
We may update this Privacy Policy periodically. We will notify you of significant changes via:

• Email notification
• In-app notification
• Prominent notice on our website

Your continued use of our services after changes constitutes acceptance of the updated policy.
''',
    ),
    LegalSection(
      title: '13. Contact Us',
      content: '''
For privacy-related inquiries or to exercise your rights:

Data Protection Officer
GOLD Savings & Investment Co-operative
Email: privacy@goldcoop.com.ng
Website: www.goldcoop.com.ng/privacy

We aim to respond to all requests within 30 days.
''',
    ),
  ];
}

/// A section of legal content with title and body
class LegalSection {
  final String title;
  final String content;

  const LegalSection({required this.title, required this.content});
}
