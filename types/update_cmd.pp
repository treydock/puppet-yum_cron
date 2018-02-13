#
type Yum_cron::Update_cmd = Enum[
  'default',
  'security',
  'security-severity:Critical',
  'minimal',
  'minimal-security',
  'minimal-security-severity:Critical',
]
