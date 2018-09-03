# frozen_string_literal: true

module Pages::FullpanelsHelper
  def slides_data
    [
      {
        view: 'intro',
        order: 1,
        title: 'I’m Encore Shao',
        desc: view_desc,
        date: 10.years.ago
      },
      {
        view: 'webdeveloper',
        order: 2,
        title: 'Web Developer',
        desc: 'Over 9 years of web development experience.',
        date: 9.years.ago
      },
      {
        view: 'rubyonrails',
        order: 3,
        title: 'Ruby On Rails',
        desc: 'Over 7 years of web development experience.',
        date: 8.years.ago
      },
      {
        view: 'j2ee',
        order: 4,
        title: 'J2EE',
        desc: 'Over 2 years of web development experience.',
        date: 7.years.ago
      },
      {
        view: 'database',
        order: 5,
        title: 'Database',
        desc: 'PostgreSQL, MySQL, SQLite3, Redis, MongoDB, Memcached, etc',
        date: 6.years.ago
      },
      {
        view: 'cloud',
        order: 6,
        title: 'Cloud',
        desc: 'Amazon Cloud, Aliyun, Digital Ocean',
        date: 5.years.ago
      },
      {
        view: 'linuxserver',
        order: 7,
        title: 'Linux Server',
        desc: 'Ubuntu, Arch, CentOS, etc',
        date: 4.years.ago
      },
      {
        view: 'python',
        order: 8,
        title: 'Python',
        desc: 'Flask, Machine Learning, AI, etc',
        date: 3.years.ago
      },
      {
        view: 'chromeextension',
        order: 9,
        title: 'Chrome Extension',
        desc: 'HTML & CSS & Javascript, Google Chrome API',
        date: 2.years.ago
      },
      {
        view: 'git',
        order: 10,
        title: 'Git',
        desc: 'Git, Github, Gitlab, Gitflow, etc',
        date: 1.years.ago
      },
      {
        view: 'api',
        order: 11,
        title: 'API',
        desc: 'Facebook, Google, Twitter, Crunchbase, Salesforce, etc',
        date: 0.years.ago
      },
      {
        view: 'developmenttool',
        order: 12,
        title: 'Dev Tool',
        desc: 'VIM, Sublime, RubyMine, TextMate, Atom, etc',
        date: 6.months.ago
      },
      {
        view: 'uxdesigner',
        order: 13,
        title: 'UX Designer',
        desc: 'User Experience (UX) Design',
        date: 3.months.ago
      },
      {
        view: 'technologies',
        order: 14,
        title: 'Technologies',
        desc: 'Ruby on Rails, Swift (iOS), Java (Android), HTML5, and CSS3',
        date: 0.months.ago
      }
    ]
  end

  def panes_data
    slides_data.collect { |option|
      extra_options = {
        left: {
          title: option[:title],
          desc: option[:desc]
        },
        right: {
          title: option[:title],
          desc: option[:desc]
        }
      }

      option.merge!(extra_options)
    }
  end

  def dates_data
    slides_data
  end

  def view_desc
    "Worked at Ekohe and live in Shanghai, China."
  end
end
