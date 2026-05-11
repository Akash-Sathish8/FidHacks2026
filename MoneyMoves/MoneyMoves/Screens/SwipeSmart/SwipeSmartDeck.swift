import Foundation
import SwiftUI

enum SSStatKey: String, CaseIterable, Hashable {
    case wallet, career, vibe, future

    var icon: String {
        switch self {
        case .wallet: return "💰"
        case .career: return "🎯"
        case .vibe:   return "✨"
        case .future: return "🔮"
        }
    }
    var label: String {
        switch self {
        case .wallet: return "Wallet"
        case .career: return "Career"
        case .vibe:   return "Vibe"
        case .future: return "Future"
        }
    }
}

struct SSChoice {
    let label: String
    let deltas: [SSStatKey: Int]
    let fairy: String
}

struct SSCard: Identifiable {
    let id = UUID()
    let year: Int               // 1-4
    let scene: String
    let body: String            // may contain *italic* markup using markdown-ish convention
    let yes: SSChoice
    let no: SSChoice
}

// Year metadata
let SS_YEAR_NAMES = ["", "Freshman", "Sophomore", "Junior", "Senior"]
let SS_YEAR_SUBS  = ["", "It begins.", "Sharper edges.", "The stakes rise.", "Everything ends, beautifully."]

// MARK: - Deck (44 cards)

let SS_DECK: [SSCard] = [
    // ============ FRESHMAN ============
    SSCard(year: 1, scene: "First Paycheck",
        body: "Your work-study deposits *$420*. Set up auto-split: 50% checking, 50% savings?",
        yes: SSChoice(label: "Split it", deltas: [.wallet: 10, .future: 15, .vibe: -5],
                      fairy: "Pay yourself first. Money you don't see is money you don't spend."),
        no:  SSChoice(label: "All checking", deltas: [.wallet: 18, .future: -5, .vibe: 5],
                      fairy: "Easy access = easy spend. People save *3× more* when it's automatic.")),

    SSCard(year: 1, scene: "Spring Break",
        body: "Roommates booked Cabo. *$850* Venmo due tonight. They'll never let you live it down.",
        yes: SSChoice(label: "Send it", deltas: [.wallet: -22, .vibe: 18, .future: -10],
                      fairy: "Memories matter — but $850 invested at 19 grows to *~$13K* by retirement."),
        no:  SSChoice(label: "Sit it out", deltas: [.wallet: 2, .vibe: -15, .future: 6],
                      fairy: "Saying no to FOMO is a real money move. Your future self just got richer.")),

    SSCard(year: 1, scene: "Free Swag Trap",
        body: "Guy at the student union: free t-shirt if you sign up for a credit card. The shirt is cute.",
        yes: SSChoice(label: "Sign up", deltas: [.wallet: -3, .future: -15, .vibe: 5],
                      fairy: "Kiosk cards charge *25%+ APR*. Get a card — but from your bank, not a folding table."),
        no:  SSChoice(label: "Walk away", deltas: [.future: 10, .career: 3],
                      fairy: "Your first credit card should come from research, not a free shirt.")),

    SSCard(year: 1, scene: "The Roth Conversation",
        body: "Parents say they'll match anything you put in a Roth IRA this year. They suggest *$50/mo*.",
        yes: SSChoice(label: "Open it", deltas: [.wallet: -8, .future: 25, .career: 5],
                      fairy: "Roth at 19 = the most powerful financial move of your life. *Compound interest is your superpower.*"),
        no:  SSChoice(label: "Not yet", deltas: [.wallet: 6, .future: -12],
                      fairy: "Every year you wait costs you ~$30K at retirement. Just so you know.")),

    SSCard(year: 1, scene: "Rush Week",
        body: "Sorority dues are *$1,200/semester*. But the bid letter is in your hand.",
        yes: SSChoice(label: "Accept bid", deltas: [.wallet: -22, .vibe: 20, .career: 10],
                      fairy: "Greek networks can pay off — but only if you actually use them."),
        no:  SSChoice(label: "Pass", deltas: [.wallet: 10, .vibe: -12, .career: -3],
                      fairy: "There are 100 ways to find your people in college. This was just one.")),

    SSCard(year: 1, scene: "The Costco Venmo",
        body: "Roommate hit you with a *$34.50* Venmo for a Costco run you barely used.",
        yes: SSChoice(label: "Just pay", deltas: [.wallet: -5, .vibe: 10],
                      fairy: "Small generosities compound socially — but don't be the friend who's *always* paying."),
        no:  SSChoice(label: "Itemize back", deltas: [.wallet: 6, .vibe: -10, .career: 5],
                      fairy: "Negotiating small stuff trains you for the big stuff: salaries, rent, raises.")),

    SSCard(year: 1, scene: "Textbook Hustle",
        body: "Econ 101 book: *$280* new, *$90* used, *$0* sketchy PDF from a Reddit user.",
        yes: SSChoice(label: "Used copy", deltas: [.wallet: -8, .career: 8, .future: 5],
                      fairy: "Same content, 70% off. Your professor doesn't care which edition."),
        no:  SSChoice(label: "Find the PDF", deltas: [.wallet: 4, .career: -10],
                      fairy: "Saved cash, but if problem numbers don't match the homework, your grade pays.")),

    SSCard(year: 1, scene: "The Barista Offer",
        body: "Off-campus coffee shop: *$18/hr*, 15 hrs/week. Means dropping a club.",
        yes: SSChoice(label: "Take it", deltas: [.wallet: 18, .career: 5, .vibe: -10, .future: 5],
                      fairy: "Income now > image now. But protect that GPA — your degree is the bigger paycheck."),
        no:  SSChoice(label: "Stay in club", deltas: [.wallet: -5, .career: 10, .vibe: 10],
                      fairy: "Career capital compounds too. Sometimes the unpaid thing pays better in 3 years.")),

    SSCard(year: 1, scene: "TikTok Made Me",
        body: "Your favorite creator dropped a *$180* skincare set. 'Treat yourself' energy is loud.",
        yes: SSChoice(label: "Add to cart", deltas: [.wallet: -14, .vibe: 10, .future: -5],
                      fairy: "Treating yourself isn't bad — making it a habit is. Set a 'fun money' budget, no guilt."),
        no:  SSChoice(label: "Close the app", deltas: [.wallet: 5, .vibe: -4, .future: 6],
                      fairy: "The 'no' nobody sees you make is where wealth quietly happens.")),

    SSCard(year: 1, scene: "Mom's Budgeting App",
        body: "Mom keeps sending you links to budgeting apps. She means well. She is also relentless.",
        yes: SSChoice(label: "Set it up", deltas: [.future: 18, .wallet: 6, .vibe: -8],
                      fairy: "You can't grow what you can't see. 20 min/week beats 20 hours of panic later."),
        no:  SSChoice(label: "Vibes only", deltas: [.future: -10, .wallet: -8, .vibe: 5],
                      fairy: "Vibes-based budgeting works… until rent's due. Try it, fail, come back.")),

    SSCard(year: 1, scene: "Period Pivot",
        body: "Switch to a menstrual cup (*$35* once) vs. keep buying tampons (*$15/mo*)?",
        yes: SSChoice(label: "Try the cup", deltas: [.wallet: 8, .future: 6, .vibe: -3],
                      fairy: "$180/yr saved for 30 years = *$5,400*. Small recurring wins are wealth's secret weapon."),
        no:  SSChoice(label: "Stay the same", deltas: [.wallet: -4, .vibe: 4],
                      fairy: "Convenience has a price. Just know you're paying it.")),

    // ============ SOPHOMORE ============
    SSCard(year: 2, scene: "Lease Signing",
        body: "Two options: 1 roommate at *$1,100/mo* your share, or 3 roommates at *$550/mo*.",
        yes: SSChoice(label: "1 roommate", deltas: [.wallet: -22, .vibe: 15, .future: -10],
                      fairy: "Sometimes peace = priceless. But lifestyle creep starts here. Be honest about why."),
        no:  SSChoice(label: "3 roommates", deltas: [.wallet: 20, .vibe: -10, .future: 15],
                      fairy: "Extra $550/mo saved at 22 = *$1.4M* at 65. Roommates are an investment.")),

    SSCard(year: 2, scene: "Bachelorette Tax",
        body: "Friend's bachelorette in Nashville: *$475* all-in. You barely know the bride.",
        yes: SSChoice(label: "Go anyway", deltas: [.wallet: -18, .vibe: 10, .future: -5],
                      fairy: "Friendship tax is real. Just make sure the ROI matches what you're spending."),
        no:  SSChoice(label: "Decline kindly", deltas: [.wallet: 6, .vibe: -12],
                      fairy: "'I can't afford it' is a complete sentence. Real friends understand.")),

    SSCard(year: 2, scene: "Subscription Audit",
        body: "Spotify, Netflix, Hulu, Apple Music, Disney+, Paramount+. *$72/mo* total. Cancel three?",
        yes: SSChoice(label: "Audit time", deltas: [.wallet: 14, .vibe: -5, .future: 10],
                      fairy: "$72/mo cut = *$864/year* you can spend with intention. Subscriptions count on you forgetting."),
        no:  SSChoice(label: "Keep all", deltas: [.wallet: -10, .vibe: 5],
                      fairy: "$72/mo for 10 years = $8,640. Half your subscriptions don't even know you're alive.")),

    SSCard(year: 2, scene: "Internship Fork",
        body: "Prestigious unpaid internship at the dream brand, OR mid-tier company paying *$22/hr*.",
        yes: SSChoice(label: "Prestigious", deltas: [.wallet: -15, .career: 20, .future: 5],
                      fairy: "Brand-name internships open doors — but only take them if you can afford to."),
        no:  SSChoice(label: "Paid mid-tier", deltas: [.wallet: 18, .career: 8],
                      fairy: "Money in your pocket + real experience > a logo on LinkedIn. Most days.")),

    SSCard(year: 2, scene: "Laptop Decision",
        body: "Your laptop is dying. New one: *$1,200* cash, or 12 monthly payments at 0% APR.",
        yes: SSChoice(label: "Pay cash", deltas: [.wallet: -24, .future: 10],
                      fairy: "Owning > owing. As long as it doesn't drain your emergency fund."),
        no:  SSChoice(label: "12-mo plan", deltas: [.wallet: -10, .future: 5, .vibe: 5],
                      fairy: "0% APR is genuinely free money — IF you pay on time. *One late fee kills the deal.*")),

    SSCard(year: 2, scene: "Honors Housing",
        body: "Honors dorm opens up — *$300/mo cheaper*, quieter, less social. You'd save $3,600/year.",
        yes: SSChoice(label: "Move in", deltas: [.wallet: 18, .vibe: -10, .career: 10],
                      fairy: "$3,600/yr for two years = study abroad money. Or the start of a down payment."),
        no:  SSChoice(label: "Stay social", deltas: [.wallet: -10, .vibe: 12, .future: -5],
                      fairy: "College memories ARE the ROI sometimes. But know what you're paying for.")),

    SSCard(year: 2, scene: "Side Hustle Pick",
        body: "Tutor freshman calc at *$30/hr* (steady) OR resell vintage on Depop (variable, fun).",
        yes: SSChoice(label: "Tutor", deltas: [.wallet: 14, .career: 10, .vibe: -5],
                      fairy: "Tutoring builds a resume AND a paycheck. Both stocks go up."),
        no:  SSChoice(label: "Depop store", deltas: [.wallet: 5, .career: 5, .vibe: 10],
                      fairy: "Depop teaches real business skills: pricing, branding, customer service. Track inventory.")),

    SSCard(year: 2, scene: "Boutique Gym",
        body: "*$89/mo* Pilates studio you'll actually go to, vs. free rec center you mostly won't.",
        yes: SSChoice(label: "Studio", deltas: [.wallet: -13, .vibe: 12, .future: -5],
                      fairy: "If it's the only way you'll actually go, it pays for itself."),
        no:  SSChoice(label: "Rec center", deltas: [.wallet: 6, .vibe: -6, .future: 6],
                      fairy: "Same gains, $1,000/year saved. Your body doesn't know it's a free gym.")),

    SSCard(year: 2, scene: "Used Car Question",
        body: "Your old ride died. Used Civic for *$5,500* cash, or keep using rideshare?",
        yes: SSChoice(label: "Buy car", deltas: [.wallet: -28, .vibe: 12, .future: -10],
                      fairy: "Cars are wealth killers — insurance, gas, repairs. Worth it only if you really need one."),
        no:  SSChoice(label: "Rideshare it", deltas: [.wallet: 6, .vibe: -10, .future: 12],
                      fairy: "$5,500 invested at 20 = *$80K* at 65. Rideshare is the cheaper limo.")),

    SSCard(year: 2, scene: "Florence Calling",
        body: "Study abroad — Florence, spring semester. *$4,000* above tuition, would need a small loan.",
        yes: SSChoice(label: "Go to Italy", deltas: [.wallet: -18, .vibe: 22, .career: 10, .future: -15],
                      fairy: "Some experiences earn back their cost in worldview alone. Read the loan terms first."),
        no:  SSChoice(label: "Stay put", deltas: [.wallet: 6, .vibe: -10, .career: -3],
                      fairy: "Italy will still be there at 35 — with a passport and a bigger budget.")),

    SSCard(year: 2, scene: "The MLM Pitch",
        body: "Friend invites you to her 'opportunity' — *$300* starter kit, 'be your own boss.'",
        yes: SSChoice(label: "Join in", deltas: [.wallet: -22, .career: -10, .future: -15, .vibe: 8],
                      fairy: "*73% of MLM participants lose money.* This is a red flag in a friendship bracelet."),
        no:  SSChoice(label: "Decline kindly", deltas: [.wallet: 5, .career: 5, .future: 10, .vibe: -5],
                      fairy: "Saying no to an MLM is saying yes to your bank account AND your dignity.")),

    // ============ JUNIOR ============
    SSCard(year: 3, scene: "NYC Internship",
        body: "Summer internship in Manhattan: *$24/hr*. But rent for a closet there is *$1,800/mo*.",
        yes: SSChoice(label: "Take it", deltas: [.wallet: -12, .career: 25, .vibe: 12, .future: 5],
                      fairy: "Big-city internships pay in network, not cash. Plan housing math *before* saying yes."),
        no:  SSChoice(label: "Stay local", deltas: [.wallet: 10, .career: 6, .vibe: -5],
                      fairy: "Local can mean less competition for full-time offers. Sometimes the smart move is the boring one.")),

    SSCard(year: 3, scene: "First Negotiation",
        body: "Internship offer: *$50K* equivalent. You researched the market — *$58K* is fair.",
        yes: SSChoice(label: "Counter", deltas: [.wallet: 18, .career: 15, .vibe: -5],
                      fairy: "Women negotiate *30% less often* than men. Every $8K is $250K+ over a career."),
        no:  SSChoice(label: "Accept it", deltas: [.career: -8, .future: -12],
                      fairy: "Your first salary anchors every raise after. Negotiate now or live with it forever.")),

    SSCard(year: 3, scene: "Birthday Money",
        body: "Aunt sent *$500* for your birthday. Index fund or that meme stock from TikTok?",
        yes: SSChoice(label: "Index fund", deltas: [.future: 22, .wallet: 4],
                      fairy: "S&P 500 = boring + 10% historical return. *Boring is the cheat code.*"),
        no:  SSChoice(label: "Meme stock", deltas: [.future: -15, .vibe: 10, .wallet: -5],
                      fairy: "Speculation is gambling with extra steps. Have fun money, but never bet rent.")),

    SSCard(year: 3, scene: "Cosign Request",
        body: "Roommate wants you to cosign her credit card. *'I'll never miss a payment, promise.'*",
        yes: SSChoice(label: "Cosign", deltas: [.future: -22, .vibe: 8],
                      fairy: "If she misses ONE payment, YOUR credit tanks for 7 years. *Love is not collateral.*"),
        no:  SSChoice(label: "Decline", deltas: [.future: 12, .vibe: -10],
                      fairy: "Saying no protected your credit AND the friendship. Never cosign for anyone.")),

    SSCard(year: 3, scene: "Career Fair Fit",
        body: "Tomorrow's career fair. *$220* blazer that fits perfectly, or thrift one for $20?",
        yes: SSChoice(label: "Buy nice", deltas: [.wallet: -10, .career: 12],
                      fairy: "A great-fitting blazer is a career asset. Cost-per-wear over 4 years = pennies."),
        no:  SSChoice(label: "Thrift it", deltas: [.wallet: 5, .career: 4, .vibe: 5],
                      fairy: "Hiring managers care about you, not your tag. Thrift looks great on camera.")),

    SSCard(year: 3, scene: "HSA Confusion",
        body: "Summer job offers HSA: *$50/mo pretax*. HR didn't explain it. You're healthy.",
        yes: SSChoice(label: "Opt in", deltas: [.future: 18, .wallet: -5],
                      fairy: "HSA = the only *triple-tax-advantaged* account. Most powerful retirement tool nobody talks about."),
        no:  SSChoice(label: "Skip it", deltas: [.future: -8, .wallet: 6],
                      fairy: "If you're healthy, HSA is free money. You'll find out the hard way at 35.")),

    SSCard(year: 3, scene: "Grad School Prep",
        body: "*$1,500* LSAT/GRE course (live, structured) or self-study with library books?",
        yes: SSChoice(label: "Take course", deltas: [.wallet: -18, .career: 15, .future: 5],
                      fairy: "Test scores = scholarship money. *$1,500 in* can mean $30K off tuition."),
        no:  SSChoice(label: "Self-study", deltas: [.wallet: 5, .career: 4, .vibe: -8],
                      fairy: "Self-study works for the disciplined. Be honest about which you are.")),

    SSCard(year: 3, scene: "Networking Night",
        body: "*$50* ticket to an alumni mixer. Three people from your dream company confirmed.",
        yes: SSChoice(label: "Go", deltas: [.wallet: -5, .career: 22, .vibe: -5],
                      fairy: "*$50 for a single warm intro* is the cheapest ROI in your entire career."),
        no:  SSChoice(label: "Skip", deltas: [.wallet: 5, .career: -10],
                      fairy: "Networking feels gross until you realize it's just being curious about people on purpose.")),

    SSCard(year: 3, scene: "Filler Energy",
        body: "Bestie's getting lip filler (*$600*). She wants you to 'come for support' (and do it too).",
        yes: SSChoice(label: "Get it too", deltas: [.wallet: -18, .vibe: 10, .future: -10],
                      fairy: "Cosmetic stuff isn't 'bad spending' — but it IS recurring. Filler is a $600/yr subscription."),
        no:  SSChoice(label: "Just support", deltas: [.vibe: -5, .future: 6],
                      fairy: "You don't have to match every choice your friends make. That's a money skill AND a life one.")),

    SSCard(year: 3, scene: "Therapy Now",
        body: "School has free therapy with 6-week wait, OR *$150/session* privately, this week.",
        yes: SSChoice(label: "Pay now", deltas: [.wallet: -14, .vibe: 18, .career: 5],
                      fairy: "*Mental health IS financial health.* Burnout costs more than therapy."),
        no:  SSChoice(label: "Wait", deltas: [.wallet: 5, .vibe: -12],
                      fairy: "Free is real money saved. Just don't white-knuckle it if you're really not okay.")),

    SSCard(year: 3, scene: "Salary Transparency",
        body: "Older coworker casually mentions her pay. She makes *$12K more* than you for the same role.",
        yes: SSChoice(label: "Ask for review", deltas: [.wallet: 15, .career: 15, .vibe: -5],
                      fairy: "Pay transparency is a feature, not a bug. Data is your best negotiation tool."),
        no:  SSChoice(label: "Stay quiet", deltas: [.wallet: -5, .career: -10, .vibe: 5],
                      fairy: "The gap doesn't close by itself. It grows.")),

    // ============ SENIOR ============
    SSCard(year: 4, scene: "The Big Choice",
        body: "Dream company offer: *$58K*. Boring company offer: *$78K*. Same start date.",
        yes: SSChoice(label: "Dream job", deltas: [.wallet: -8, .career: 22, .vibe: 15, .future: 5],
                      fairy: "Career capital matters most in your 20s. Sometimes you pay tuition to your future."),
        no:  SSChoice(label: "Boring + money", deltas: [.wallet: 22, .career: 5, .vibe: -10, .future: 12],
                      fairy: "*$20K extra/year* is a paid-off car, a maxed Roth, and an emergency fund — every year.")),

    SSCard(year: 4, scene: "The 401(k)",
        body: "New job offers 401(k) match up to 6%. Default is 0%. HR didn't push it.",
        yes: SSChoice(label: "Max the match", deltas: [.future: 25, .wallet: -5],
                      fairy: "Employer match = a *100% instant return*. Refusing it is leaving free money on the table."),
        no:  SSChoice(label: "Skip for now", deltas: [.future: -22, .wallet: 8],
                      fairy: "You just turned down a raise. Go fix this on Monday.")),

    SSCard(year: 4, scene: "Counter Offer",
        body: "Recruiter said 'best and final.' Your gut says the number's still flexible.",
        yes: SSChoice(label: "Counter anyway", deltas: [.wallet: 18, .career: 15, .vibe: -5],
                      fairy: "*'Best and final' is a script.* Counter politely — 73% of negotiations succeed."),
        no:  SSChoice(label: "Accept it", deltas: [.wallet: 0, .career: -10],
                      fairy: "You'll get raises, but they're all a % of this number. Always counter.")),

    SSCard(year: 4, scene: "Greece Trip",
        body: "Senior trip to Santorini with 5 best friends: *$2,300* all-in. Last summer like this.",
        yes: SSChoice(label: "Pack a bag", deltas: [.wallet: -24, .vibe: 22, .future: -10],
                      fairy: "Some moments only exist once. *Just don't put it on a credit card.*"),
        no:  SSChoice(label: "Stay back", deltas: [.wallet: 10, .vibe: -15],
                      fairy: "Greece will be cheaper at 30 when you can actually afford it.")),

    SSCard(year: 4, scene: "City vs. Town",
        body: "Move to NYC for the job (rent *$2,400*) or take the WFH offer in your college town (*$900*)?",
        yes: SSChoice(label: "NYC", deltas: [.wallet: -24, .career: 20, .vibe: 15, .future: -5],
                      fairy: "Cities are career accelerators in your 20s. The cost is real but so are the connections."),
        no:  SSChoice(label: "WFH local", deltas: [.wallet: 22, .career: -3, .vibe: -10, .future: 15],
                      fairy: "*$18K/yr saved* in your first job out = generational wealth math. Geography is leverage.")),

    SSCard(year: 4, scene: "The Card Balance",
        body: "Credit card balance: *$1,800 at 24% APR*. Emergency fund: $0. First real paycheck just hit.",
        yes: SSChoice(label: "Kill the card", deltas: [.wallet: -14, .future: 22, .vibe: -5],
                      fairy: "*24% APR is a financial fire.* Always put out fires before storing water."),
        no:  SSChoice(label: "E-fund first", deltas: [.wallet: -10, .future: 10, .vibe: 6],
                      fairy: "Solid logic, but at 24% you're losing money every month you wait.")),

    SSCard(year: 4, scene: "Wedding Season",
        body: "Four weddings this summer. Travel + gifts + dresses ≈ *$1,400* total.",
        yes: SSChoice(label: "Go to all", deltas: [.wallet: -22, .vibe: 15, .future: -10],
                      fairy: "Be present in your friends' lives — within reason. Set a wedding budget BEFORE saying yes."),
        no:  SSChoice(label: "Decline two", deltas: [.wallet: -3, .vibe: -5, .future: 8],
                      fairy: "Real friends don't keep score. *Two thoughtful gifts > four resentful trips.*")),

    SSCard(year: 4, scene: "Interview Wardrobe",
        body: "Job hunting hard. Buy 2 interview suits (*$600*) or rent per round at $90 each?",
        yes: SSChoice(label: "Buy them", deltas: [.wallet: -13, .career: 10, .future: 5],
                      fairy: "If you'll interview 6+ times in 2 years, buying wins. After that, it's free."),
        no:  SSChoice(label: "Rent each", deltas: [.wallet: -5, .career: 5],
                      fairy: "Rental works for short hunts. Just don't get caught in the same dress twice.")),

    SSCard(year: 4, scene: "Signing Bonus",
        body: "Bonus options: *$5,000 cash now* OR *$7,000 in company stock* vesting in 2 years.",
        yes: SSChoice(label: "Take cash", deltas: [.wallet: 22, .future: -5],
                      fairy: "Cash is certain. If you have debt or no e-fund, this is the right call."),
        no:  SSChoice(label: "Take stock", deltas: [.wallet: -5, .future: 20, .career: 5],
                      fairy: "If the company's healthy and you have runway, vesting almost always wins.")),

    SSCard(year: 4, scene: "Graduation Glam",
        body: "Grad week: *$400* dress + *$300* photos + *$200* family dinner.",
        yes: SSChoice(label: "Full glam", deltas: [.wallet: -18, .vibe: 15],
                      fairy: "Ceremony moments matter. Just don't go into debt for one Sunday."),
        no:  SSChoice(label: "Keep it low-key", deltas: [.wallet: 10, .vibe: -5],
                      fairy: "Photos exist on every phone in your family already. Save the $900.")),

    SSCard(year: 4, scene: "Health Insurance",
        body: "You age off your parents' plan in 6 months. Sign up for employer plan now, or wait?",
        yes: SSChoice(label: "Sign up now", deltas: [.wallet: -8, .future: 18, .vibe: 5],
                      fairy: "One ER visit uninsured = $5,000+. The 'cheap' move is always coverage."),
        no:  SSChoice(label: "Wait it out", deltas: [.wallet: 5, .future: -15, .vibe: -8],
                      fairy: "*62% of personal bankruptcies* involve medical debt. Don't be a statistic.")),
]

// MARK: - Markdown-ish *italic* renderer for body / fairy text.
// Splits a string on `*` into runs; odd-indexed runs render italic+coral.

struct SSText: View {
    let raw: String
    var size: CGFloat
    var color: Color
    var emColor: Color

    init(_ raw: String, size: CGFloat = 17, color: Color = SSPalette.ink, emColor: Color = SSPalette.coral) {
        self.raw = raw
        self.size = size
        self.color = color
        self.emColor = emColor
    }

    var body: some View {
        let parts = raw.components(separatedBy: "*")
        return parts.enumerated().reduce(Text("")) { acc, pair in
            let (i, run) = pair
            if i % 2 == 0 {
                return acc + Text(run).foregroundColor(color)
            } else {
                return acc + Text(run).italic().foregroundColor(emColor)
            }
        }
        .font(SSFont.serif(size, weight: .regular))
    }
}
