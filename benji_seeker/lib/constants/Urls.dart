// const String BASE_URL = "https://getbenji.com/api/";
const String BASE_URL = "https://dev.getbenji.com/api/";
// const String BASE_URL_CATEGORY = "https://getbenji.com/uploads/sub_categories/";
// const String BASE_PROFILE_URL = "https://getbenji.com/api/uploads/profile_pictures/";
const String BASE_URL_CATEGORY = "https://dev.getbenji.com/uploads/sub_categories/";
const String BASE_PROFILE_URL = "https://dev.getbenji.com/uploads/profile_pictures/";
const String BASE_JOB_IMAGE_URL = "https://dev.getbenji.com/uploads/jobs/";
// const String BASE_JOB_IMAGE_URL = "https://getbenji.com/uploads/jobs/";

const String BASE_GOOGLE_AUTOCOMPLETE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
const String BASE_GOOGLE_PLACE_DETAIL_URL = "https://maps.googleapis.com/maps/api/place/details/json";

const String URL_LOGIN = "user/login";
const String URL_VERIFY_TOKEN = "user/verify-token";
const String URL_PHONENUMBER_CHECK = "phone/check";
const String URL_UPCOMING_JOBS = "job/upcoming";
//const String URL_CATEGORIES = "categories/all";
const String URL_MESSAGES_UNREAD = "message/unread";
const String URL_USER_BASIC_INFO = "user/basic-info";
const String URL_SUB_CATEGORIES = "sub-categories/all";
const String URL_ALL_NOTIFICATIONS = "notifications/all";
const String URL_READ_NOTIFICATION = "notifications/read";
const String URL_COMPLETED_JOBS = "job/completed-jobs";
const String URL_GET_BANK_DETAILS = "seeker/payment-details";
const String URL_UPDATE_BANK_DETAILS = "seeker/edit/payment-details";
const String URL_INVITE = "send-invitation";
const String URL_CHECK_ADDRESS = "job/check-address";
const String URL_CREATE_JOB = "job/create";
const String URL_ACCEPT_BID = "job/accept-bid";
const String URL_RESCHEDULE_JOB = "job/reschedule";
const String URL_CANCEL_JOB = "job/cancel";
const String URL_SIGN_UP = "seeker/signup";
const String URL_PHONE_VERIFY = "phone/verify";
const String URL_RESEND_OTP = "phone/resend-otp";
const String URL_UPDATE_PROFILE = "user/edit/about-me";
const String URL_UPDATE_PHONE_NUMBER = "user/edit/about-me/phone";
const String URL_ADD_TIP = "job/add-tip";
const String URL_REVIEW = "job/rate-provider";
const String URL_HELP = "get-help/seeker";
const String URL_FEEDBACK = "submit-feedback";
const String URL_MESSAGE_SEND = "message/send";
const String URL_DEVICE_TOKEN = "user/update/device-token";
const String URL_UNREAD_COUNTS = "app/header-info";
const String URL_FORGOT_PASSWORD = "user/forgot-password";
const String URL_SKIP_JOB = "job/skip";
const String URL_NOTIFY_OF_ZIP_CODE = "service-location-request/add";

String URL_UPCOMING(String year){
  return "job/upcoming/$year";
}


String URL_SUB_CATRGORY_DETAIL(String subCategoryID){
  return 'sub-categories/$subCategoryID/tasks/all';
}

String URL_JOB_DETAIL(String jobID){
  return 'job/$jobID';
}

String URL_JOB_BIDS(String jobID){
  return "job/bids/$jobID";
}

String URL_PROVIDER_DETAIL(String id){
  return "provider/$id";
}

String URL_COMPLETED_JOB(String id){
  return "job/completion-data/$id";
}

String URL_SUMMARY(String id){
  return "job/summary/$id";
}

String URL_MESSAGES(String processId){
  return "message/$processId/all";
}

String URL_CHECK_ZIP_CODE(String zipCode){
  return "service-location/$zipCode";
}