module RedmineUnreadIssuesIndicator
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag('unread_indicator', plugin: 'redmine_unread_issues_indicator') +
      javascript_tag(unread_indicator_script(context))
    end

    private

    def javascript_tag(script)
      return '' if script.blank?
      "<script type=\"text/javascript\">\n//<![CDATA[\n#{script}\n//]]>\n</script>".html_safe
    end

    def unread_indicator_script(context)
      <<-JS
        (function() {
          // Функция получения непрочитанных ID с сервера
          function fetchUnreadStatus(issueIds, callback) {
            if (issueIds.length === 0) {
              callback([]);
              return;
            }
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/unread_issues?ids=' + issueIds.join(','), true);
            xhr.onload = function() {
              if (xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                callback(data.unread_ids);
              } else {
                callback([]);
              }
            };
            xhr.onerror = function() { callback([]); };
            xhr.send();
          }

          // Функция добавления индикаторов в строки таблицы
          function addIndicators() {
            var rows = document.querySelectorAll('tr.issue');
            if (rows.length === 0) return;

            // Собираем все ID задач на странице
            var allIds = [];
            rows.forEach(function(row) {
              var idElement = row.querySelector('td.id a');
              if (idElement) {
                var id = parseInt(idElement.textContent.trim(), 10);
                if (id) allIds.push(id);
              }
            });

            fetchUnreadStatus(allIds, function(unreadIds) {
              rows.forEach(function(row) {
                if (row.dataset.indicatorProcessed) return;
                row.dataset.indicatorProcessed = '1';

                var idElement = row.querySelector('td.id a');
                if (!idElement) return;
                var issueId = parseInt(idElement.textContent.trim(), 10);

                if (unreadIds.includes(issueId)) {
                  var subjectElement = row.querySelector('td.subject a');
                  if (subjectElement) {
                    var dot = document.createElement('span');
                    dot.className = 'issue-unread-indicator';
                    dot.innerHTML = '&#9679;';
                    subjectElement.parentNode.insertBefore(dot, subjectElement);
                  }
                }
              });
            });
          }

          // Выполняем при загрузке
          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', addIndicators);
          } else {
            addIndicators();
          }

          // Наблюдаем за появлением новых строк (AJAX-догрузка, динамические списки)
          var observer = new MutationObserver(function(mutations) {
            // Проверяем, появились ли новые tr.issue
            var hasNewRows = mutations.some(function(mut) {
              return [].slice.call(mut.addedNodes).some(function(node) {
                return node.nodeType === 1 && (node.matches('tr.issue') || node.querySelector('tr.issue'));
              });
            });
            if (hasNewRows) {
              // Сбрасываем флаг processed у всех строк, чтобы обновить индикаторы
              document.querySelectorAll('tr.issue').forEach(function(row) {
                delete row.dataset.indicatorProcessed;
              });
              addIndicators();
            }
          });
          observer.observe(document.body, { childList: true, subtree: true });
        })();
      JS
    end
  end
end
