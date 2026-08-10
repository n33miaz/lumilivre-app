// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LumiLivre';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearanceSection => '外观';

  @override
  String get languageSection => '语言';

  @override
  String get securitySection => '安全';

  @override
  String get accountSection => '账户';

  @override
  String get themeLabel => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeDark => '深色';

  @override
  String get languagePortuguese => '葡萄牙语（巴西）';

  @override
  String get languageEnglish => '英语（美国）';

  @override
  String get languageSpanish => '西班牙语（西班牙）';

  @override
  String get languageChinese => '中文（简体）';

  @override
  String get languageHindi => '印地语（印度）';

  @override
  String get biometricAccess => '生物识别登录';

  @override
  String get biometricSubtitle => '使用指纹或面容登录。';

  @override
  String get biometricUnavailable => '此设备不支持生物识别。';

  @override
  String get biometricEnablePrompt => '请验证身份以开启生物识别登录。';

  @override
  String get biometricUnlockPrompt => '请验证身份以继续使用 LumiLivre。';

  @override
  String get biometricEnableFailed => '无法验证你的身份，生物识别仍处于关闭状态。';

  @override
  String get biometricEnabledConfirmation => '已开启生物识别。下次打开应用时会要求验证。';

  @override
  String get changePassword => '修改密码';

  @override
  String get logout => '退出登录';

  @override
  String get guestSettingsPrompt => '登录后可使用全部设置';

  @override
  String get loginAction => '登录';

  @override
  String get guestName => '访客';

  @override
  String get guestAccessDisabled => '本图书馆已关闭访客访问。';

  @override
  String get retryAction => '重试';

  @override
  String get sessionExpiredMessage => '登录已过期，请重新登录以继续。';

  @override
  String get connectionErrorMessage => '无法连接服务器。请检查网络后重试。';

  @override
  String get loginFailedMessage => '登录失败。请检查学号和密码。';

  @override
  String get linkOpenError => '无法在此设备上打开链接。';

  @override
  String get offlineCachedDataMessage => '无网络连接：显示已保存的数据。';

  @override
  String get catalogRefreshError => '无法刷新馆藏目录。';

  @override
  String get bookListLoadError => '无法加载图书。请检查网络连接。';

  @override
  String get loadMoreError => '无法加载更多内容。';

  @override
  String get searchError => '暂时无法搜索图书。';

  @override
  String get passwordChangedMessage => '密码已修改。';

  @override
  String get passwordChangeFailedMessage => '密码修改失败，请重试。';

  @override
  String get passwordChangeRequiredMessage => '请先修改初始密码才能使用此功能。';

  @override
  String get avatarUploading => '正在上传照片…';

  @override
  String get avatarUploadSuccess => '照片已更新。';

  @override
  String get avatarUploadError => '无法更新照片。';

  @override
  String get loanRequestSent => '申请已提交，请等待图书馆审核。';

  @override
  String get loanRequestFailed => '暂时无法申请借阅这本书。';

  @override
  String get penaltyNoticeTitle => '借阅暂时停用';

  @override
  String penaltyNoticeUntil(String date) {
    return '你将于 $date 恢复借阅。';
  }

  @override
  String penaltyNoticeKind(String kind) {
    return '记录为：$kind';
  }

  @override
  String get penaltyNoticeHint => '在此期间你仍可浏览馆藏和收藏图书。如有疑问，请联系图书馆。';

  @override
  String get bookDetailsLoadError => '无法加载图书详情。';

  @override
  String get guestBookTitle => '登录后查看这本书';

  @override
  String get guestBookMessage => '完整信息、在馆状态和借阅仅面向本馆读者。';

  @override
  String get profileTabLoans => '借阅';

  @override
  String get profileTabLikes => '收藏';

  @override
  String get profileTabRanking => '排行榜';

  @override
  String get guestLoansTitle => '登录后查看你的借阅';

  @override
  String get guestLoansMessage => '跟踪你正在借阅的图书和历史记录。';

  @override
  String get guestLikesTitle => '登录后收藏图书';

  @override
  String get guestLikesMessage => '收藏喜欢的图书，稍后再看。';

  @override
  String get guestRankingTitle => '登录后查看排行榜';

  @override
  String get guestRankingMessage => '在读者排行榜上比比阅读量。';

  @override
  String get readerTerm => '读者';

  @override
  String get filterRanking => '筛选排行榜';

  @override
  String get courseLabel => '专业';

  @override
  String get moduleLabel => '模块';

  @override
  String get shiftLabel => '班次';

  @override
  String get applyFilters => '应用筛选';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get emptyRankingMessage => '未找到读者。';

  @override
  String get rankingLoginPrompt => '登录后查看排行榜。';

  @override
  String get rankingUnavailable => '本图书馆未开放排行榜。';

  @override
  String get muralTitle => '公告板';

  @override
  String get muralEmpty => '这里还没有任何发布。';

  @override
  String get muralError => '无法加载公告板。请检查网络连接。';

  @override
  String get muralRetry => '重试';

  @override
  String get muralLoginPrompt => '登录后查看公告板。';

  @override
  String get muralTypeAnnouncement => '通知';

  @override
  String get muralTypeAttachment => '附件';

  @override
  String get muralTypeWork => '作业';

  @override
  String get muralOpenDocument => '打开文档';

  @override
  String get muralExternalLink => '外部链接';

  @override
  String muralByAuthors(String authors) {
    return '作者：$authors';
  }

  @override
  String get muralAuthorsLabel => '作者';

  @override
  String get muralAdvisorsLabel => '指导老师';

  @override
  String get muralYearLabel => '年份';

  @override
  String get muralSemesterLabel => '学期';

  @override
  String muralUnseenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新发布',
    );
    return '$_temp0';
  }

  @override
  String get forceUpdateTitle => '请更新应用';

  @override
  String get forceUpdateMessage => '有新的必需版本可用。请更新后继续使用 LumiLivre。';

  @override
  String get forceUpdateButton => '立即更新';

  @override
  String get forceUpdateStoreError => '无法打开应用商店。';

  @override
  String get tourSkip => '跳过';

  @override
  String get tourNext => '下一步';

  @override
  String get tourFinish => '完成';

  @override
  String get tourStep1Title => '欢迎使用 LumiLivre！';

  @override
  String get tourStep1Body => '在一个地方发现并跟踪图书馆的所有图书。';

  @override
  String get tourStep2Title => '探索馆藏';

  @override
  String get tourStep2Body => '浏览「馆藏目录」或按「分类」筛选，找到你的下一本书。';

  @override
  String get tourStep3Title => '搜索并了解最新动态';

  @override
  String get tourStep3Body => '用搜索快速找到书名，到「公告板」查看新消息和通知。';

  @override
  String get tourStep4Title => '你的空间';

  @override
  String get tourStep4Body => '在「我的」里查看借阅、更换照片并调整偏好设置。';

  @override
  String get cancelAction => '取消';

  @override
  String get saveAction => '保存';

  @override
  String get refreshAction => '刷新';

  @override
  String get logoSemanticLabel => 'LumiLivre 标志';

  @override
  String get loginSubmit => '登录';

  @override
  String get loginAsGuest => '以访客身份进入';

  @override
  String get loginUserFieldLabel => '学号或邮箱';

  @override
  String get loginUserFieldRequired => '请输入用户名';

  @override
  String get loginPasswordRequired => '请输入密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get passwordLabel => '密码';

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String get mandatoryPasswordTitle => '修改初始密码';

  @override
  String get mandatoryPasswordMessage => '为了账户安全，请先修改当前登录密码再继续。';

  @override
  String get currentPasswordLabel => '当前密码';

  @override
  String get currentPasswordRequired => '请输入当前密码';

  @override
  String get newPasswordLabel => '新密码';

  @override
  String get newPasswordRequired => '请输入新密码';

  @override
  String get confirmNewPasswordLabel => '确认新密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String passwordMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '至少 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String get awaitingPasswordChange => '等待修改密码…';

  @override
  String get navCategories => '分类';

  @override
  String get navCatalog => '馆藏目录';

  @override
  String get navProfile => '我的';

  @override
  String get searchHint => '搜索书名或作者';

  @override
  String searchResultsTitle(String query) {
    return '“$query”的搜索结果';
  }

  @override
  String get searchNoResults => '未找到图书。';

  @override
  String get browseAllTitle => '浏览全部分类';

  @override
  String get genreThesis => '毕业论文';

  @override
  String get genreAdventure => '冒险';

  @override
  String get genreRomance => '爱情';

  @override
  String get genreEducational => '教育';

  @override
  String get genreThriller => '悬疑';

  @override
  String get genreBiography => '传记';

  @override
  String get genreFiction => '小说';

  @override
  String get genreHistory => '历史';

  @override
  String get genreSelfHelp => '励志成长';

  @override
  String get genreFantasy => '奇幻';

  @override
  String get genreHorror => '恐怖';

  @override
  String get genrePoetry => '诗歌';

  @override
  String get genreScienceTechnology => '科学与技术';

  @override
  String get genreChildrenAndTeens => '少儿与青少年';

  @override
  String get categoryEmptyTitle => '未找到图书';

  @override
  String categoryEmptyMessage(String category) {
    return '“$category”下还没有登记任何图书。\n欢迎稍后再来看看新书！';
  }

  @override
  String get categoryExploreOthers => '浏览其他分类';

  @override
  String get bookDetailsTitle => '详情';

  @override
  String get bookCoverMissing => '无封面';

  @override
  String bookReleasedOn(String date) {
    return '出版于 $date';
  }

  @override
  String get bookRatingsLabel => '评分';

  @override
  String get bookCoverTypeLabel => '装帧';

  @override
  String get bookAgeRatingLabel => '适读年龄';

  @override
  String get bookPublisherLabel => '出版社';

  @override
  String get bookGenresLabel => '分类';

  @override
  String get bookSynopsisLabel => '简介';

  @override
  String get loanButtonGuest => '登录后申请借阅';

  @override
  String get loanButtonNoCopies => '未登记任何复本';

  @override
  String get loanButtonLimitReached => '已达借阅上限';

  @override
  String get loanButtonRequest => '申请借阅';

  @override
  String get loanButtonPending => '等待审核';

  @override
  String loanButtonActiveUntil(String date) {
    return '借阅至：$date';
  }

  @override
  String get loanButtonOverdue => '已超过归还日期';

  @override
  String loanButtonAvailableFrom(String date) {
    return '$date 起可借';
  }

  @override
  String get loanButtonUnavailable => '暂不可借';

  @override
  String get loansTabInProgress => '进行中';

  @override
  String get loansTabHistory => '历史记录';

  @override
  String get loansHistoryEmpty => '未找到历史记录。';

  @override
  String get loansActiveEmpty => '没有进行中的借阅或申请。';

  @override
  String get loanStatusRejected => '申请已拒绝';

  @override
  String get loanStatusPending => '等待审核';

  @override
  String get loanStatusReturned => '已归还';

  @override
  String loanStatusOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已逾期（$count 天）',
    );
    return '$_temp0';
  }

  @override
  String get loanStatusDueToday => '今天到期！';

  @override
  String loanStatusDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天后归还',
    );
    return '$_temp0';
  }

  @override
  String loanRequestedOn(String date) {
    return '申请日期：$date';
  }

  @override
  String loanBorrowedOn(String date) {
    return '借出日期：$date';
  }

  @override
  String get likesEmptyMessage => '你还没有收藏任何图书。';

  @override
  String profileSubtitleWithRank(String registration, String rank) {
    return '$registration · 排名：$rank';
  }

  @override
  String get offlineBannerMessage => '当前离线，显示已保存的数据。';

  @override
  String apiHealthWakingBanner(String elapsed) {
    return '服务器正在唤醒… $elapsed';
  }

  @override
  String get apiHealthWakingToast =>
      '服务器此前处于休眠状态，正在启动。最长可能需要 3 分钟：应用会自动重试，并在服务器响应后立即加载内容。';

  @override
  String get apiHealthRestoredToast => '服务器已恢复，正在加载内容。';

  @override
  String get apiHealthUnreachableBanner => '服务器无响应。点击重试。';

  @override
  String get likeAction => '收藏';

  @override
  String get unlikeAction => '取消收藏';

  @override
  String get interestOfflineError => '无网络连接：收藏未保存。';

  @override
  String get interestSaveError => '无法保存收藏，请重试。';

  @override
  String interestMigratedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本机收藏的 $count 本图书已保存到你的账号。',
    );
    return '$_temp0';
  }
}
