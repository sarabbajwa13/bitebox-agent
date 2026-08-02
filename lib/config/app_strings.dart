/// Central place for all user-facing text/labels (agent app).
class AppStrings {
  AppStrings._();

  // Login
  static const String loginTitle = 'Agent login';
  static const String loginSubtitle = 'Sign in to manage your store orders';
  static const String phoneNumber = 'Phone number';
  static const String phoneRequired = 'Please enter your phone number';
  static const String phoneInvalid = 'Enter a valid 10-digit number';
  static const String sendOtp = 'Send OTP';
  static const String otpSentTo = 'Enter the OTP sent to';
  static const String otpLabel = 'OTP';
  static const String otpRequired = 'Enter the OTP';
  static const String otpInvalid = 'Enter the 6-digit OTP';
  static const String verifyLogin = 'Verify & login';
  static const String changeNumber = 'Change number';
  static const String resendOtp = 'Resend OTP';

  // Nav
  static const String ordersTab = 'Orders';
  static const String productsTab = 'Products';
  static const String storeTab = 'Store';

  // Products (admin)
  static const String productsTitle = 'Products';
  static const String addProduct = 'Add product';
  static const String editProduct = 'Edit product';
  static const String noProducts = 'No products yet';
  static const String noProductsSub =
      'Add products so customers can order them';
  static const String productName = 'Product name';
  static const String productDesc = 'Description';
  static const String productImageUrl = 'Image URL';
  static const String productImageHint = 'Paste an image link (imgbb, Cloudinary…)';
  static const String productCategory = 'Category';
  static const String isVegLabel = 'Vegetarian';
  static const String isAvailableLabel = 'Available for order';
  static const String variants = 'Variants & prices';
  static const String variantName = 'Variant (e.g. Cheese)';
  static const String priceLabel = 'Price';
  static const String addVariant = 'Add variant';
  static const String saveProduct = 'Save product';
  static const String deleteProduct = 'Delete';
  static const String deleteProductConfirm = 'Delete this product?';
  static const String nameRequired2 = 'Enter a product name';
  static const String variantRequired = 'Add at least one variant with a price';
  static const String productSaved = 'Product saved';

  // Orders
  static const String ordersTitle = 'Orders';
  static const String filterNew = 'New';
  static const String filterActive = 'Active';
  static const String filterDone = 'Completed';
  static const String noOrdersNew = 'No new orders';
  static const String noOrdersNewSub = 'New orders from customers will appear here';
  static const String noOrdersActive = 'No active orders';
  static const String noOrdersDone = 'No completed orders yet';

  // Order actions
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String startPreparing = 'Start preparing';
  static const String markOutForDelivery = 'Out for delivery';
  static const String markDelivered = 'Mark delivered';
  static const String orderDetailTitle = 'Order details';
  static const String customer = 'Customer';
  static const String items = 'Items';
  static const String total = 'Total';
  static const String rejectConfirmTitle = 'Reject this order?';
  static const String rejectConfirmBody =
      'The customer will be notified that the order was not accepted.';
  static const String cancel = 'Cancel';

  // Store settings
  static const String storeSettingsTitle = 'Store settings';
  static const String storeStatus = 'Store status';
  static const String openLabel = 'Open — accepting orders';
  static const String closedLabel = 'Closed — not visible to customers';
  static const String visibilityRadius = 'Visibility radius';
  static const String visibilityRadiusHelp =
      'Customers within this distance will see your store';
  static const String saveSettings = 'Save changes';
  static const String settingsSaved = 'Store settings saved';
  static const String logout = 'Logout';

  // Generic
  static const String km = 'km';
}
