<?php
/**
 * ============================================================
 *  VOLTA ESSENCE — Contact Form Handler
 * ============================================================
 *  File:    submit_form.php
 *  Place:   C:/xampp/htdocs/volta-essence/submit_form.php
 * ============================================================
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

// ----------------------------------------------------------
//  DATABASE CONFIGURATION
// ----------------------------------------------------------
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'volta_essence');

// ----------------------------------------------------------
//  ONLY ACCEPT POST REQUESTS
// ----------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request. This endpoint only accepts POST.'
    ]);
    exit;
}

// ----------------------------------------------------------
//  SANITIZE FUNCTION
// ----------------------------------------------------------
function sanitize($input) {
    return htmlspecialchars(strip_tags(trim($input)));
}

// ----------------------------------------------------------
//  COLLECT & CLEAN FORM DATA
// ----------------------------------------------------------
$first_name   = sanitize($_POST['first_name'] ?? '');
$last_name    = sanitize($_POST['last_name']  ?? '');
$email        = filter_var($_POST['email'] ?? '', FILTER_SANITIZE_EMAIL);
$phone        = sanitize($_POST['phone']   ?? '');
$interest     = sanitize($_POST['interest'] ?? '');
$message      = sanitize($_POST['message']  ?? '');
$ip_address   = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$submitted_at = date('Y-m-d H:i:s');

// ----------------------------------------------------------
//  VALIDATE
// ----------------------------------------------------------
$errors = [];
if (empty($first_name)) $errors[] = 'First name is required.';
if (empty($last_name))  $errors[] = 'Last name is required.';
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) $errors[] = 'A valid email address is required.';

if (!empty($errors)) {
    echo json_encode(['success' => false, 'errors' => $errors]);
    exit;
}

// ----------------------------------------------------------
//  CONNECT TO DATABASE
// ----------------------------------------------------------
try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (PDOException $e) {
    error_log('[Volta Essence] DB Connection Error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Could not connect to database. Please check XAMPP MySQL is running.'
    ]);
    exit;
}

// ----------------------------------------------------------
//  SAVE TO DATABASE
// ----------------------------------------------------------
try {
    $stmt = $pdo->prepare("
        INSERT INTO customer_enquiries
            (first_name, last_name, email, phone, interest, message, ip_address, submitted_at)
        VALUES
            (:first_name, :last_name, :email, :phone, :interest, :message, :ip_address, :submitted_at)
    ");

    $stmt->execute([
        ':first_name'   => $first_name,
        ':last_name'    => $last_name,
        ':email'        => $email,
        ':phone'        => $phone,
        ':interest'     => $interest,
        ':message'      => $message,
        ':ip_address'   => $ip_address,
        ':submitted_at' => $submitted_at,
    ]);

    $insertId = $pdo->lastInsertId();

} catch (PDOException $e) {
    error_log('[Volta Essence] DB Insert Error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Could not save your message. Please try again.'
    ]);
    exit;
}

// ----------------------------------------------------------
//  EMAIL NOTIFICATION
//  Updated to real Volta Essence contact details
// ----------------------------------------------------------
$to      = 'senyoirene123@gmail.com';   // ✅ Real Volta Essence email
$subject = "New Enquiry — $first_name $last_name | Volta Essence";

$body = "
==============================================
 NEW CUSTOMER ENQUIRY — VOLTA ESSENCE
==============================================

CUSTOMER DETAILS
-----------------
Name      : $first_name $last_name
Email     : $email
Phone     : $phone
Interest  : $interest
Date/Time : $submitted_at
IP Address: $ip_address

MESSAGE
-----------------
$message

==============================================
Reference ID : #" . str_pad($insertId, 5, '0', STR_PAD_LEFT) . "
==============================================

To reply this customer, email: $email
Or call/WhatsApp: $phone

View all enquiries at:
http://localhost/phpmyadmin
→ volta_essence → customer_enquiries
==============================================
Volta Essence | Accra, Ghana
Phone: 0557202440
Email: senyoirene123@gmail.com
==============================================
";

$headers  = "From: noreply@voltaessence.com\r\n";
$headers .= "Reply-To: $email\r\n";
$headers .= "X-Mailer: PHP/" . phpversion();

@mail($to, $subject, $body, $headers);

// ----------------------------------------------------------
//  SUCCESS RESPONSE
//  Returns the "Akpe" message shown on the webpage
// ----------------------------------------------------------
echo json_encode([
    'success'   => true,
    'message'   => 'Akpe! Your order has been received. It would be delivered shortly!',
    'reference' => '#' . str_pad($insertId, 5, '0', STR_PAD_LEFT),
]);
?>
