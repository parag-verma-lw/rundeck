%{--
  - Copyright 2019 Rundeck, Inc. (http://rundeck.com)
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%


<div id="formbuttons" data-ko-bind="runformoptions">
    <div class="">
        <div>

            <div class="col-xs-12 col-sm-4">
                <g:if test="${!hideCancel}">
%{--                    <g:actionSubmit id="execFormCancelButton" value="${g.message(code:'button.action.Cancel',default:'Cancel')}" class="btn btn-default btn-sm"/>--}%
                    <button type="button" class="btn btn-default " data-dismiss="modal">${g.message(code:'button.action.Cancel',default:'Cancel')}</button>
                </g:if>

                <input type="hidden"
                       name="extra.debug"
                       data-bind="value: debug"
                       id="extra_loglevel"

                />
                <div class="btn-group ">
                    <button type="button" class="btn btn-simple btn-secondary dropdown-toggle" data-toggle="dropdown"
                            aria-haspopup="true" aria-expanded="false">
                        <g:message code="options.label" />
                        <span class="caret"></span>
                        <span class="sr-only">Toggle Dropdown</span>
                    </button>

                    <ul class="dropdown-menu ">
                        <li>
                            <a href="#" data-bind="click: function(){debug(!debug())}">
                                <b class="fas fa-bug"></b>
                                <g:message code="run.with.debug.output" />
                                <b class="fas fa-check" data-bind="visible: debug()"></b>
                            </a>
                        </li>
                        <g:if test="${showRunLater}">
                        <li>

                            <a data-toggle="modal"
                               title="Set start time"
                               href="#scheduler">
                                <b class="glyphicon glyphicon-time"></b>
                                <g:message code="run.job.later.ellipsis"/>
                            </a>
                        </li>
                        </g:if>

                    </ul>
                </div>
                <g:render template="/common/modal"
                          model="[modalid: 'scheduler', titleCode: 'run.job.later', buttons: [
                                  [
                                          css        : 'btn btn-primary schedule-button',
                                          messageCode: 'schedule.job',
                                          js         : 'onScheduleSubmit()'
                                  ]
                          ]]">
                    <div>

                        <div class='input-group date'>
                            <input type='datetime' class='form-control' id='runAtTime' name='runAtTime' value=''
                                   placeholder="Enter a date/time"/>
                            <span class='input-group-addon'>
                                <span class='glyphicon glyphicon-calendar'></span>
                            </span>
                        </div>

                        <div id="datetimepicker"></div>

                        <div id='dateAlert' class='alert alert-warning alert-block fade' style='display: none'>
                            ${message(code: "the.time.must.be.in.the.future")}
                        </div>
                    </div>
                </g:render>
            </div>

            <div class="col-xs-12 col-sm-5">
                <div class="form-inline">
                    <div class="">

                        <input type="hidden" id="followoutputcheck" name="follow" value="true"/>


                        <div class="form-group">
                            <label>

                                <g:message code="job.run.watch.output"/>
                                <select class="form-control " name="followdetail">
                                    <option value="nodes" ${(
                                                                      !scheduledExecution.defaultTab ||
                                                                      scheduledExecution.defaultTab in
                                                                      ['summary','nodes','report']
                                                              ) ? 'selected="selected"' : ''}>
                                        <g:message code="execution.page.show.tab.Nodes.title"/>
                                    </option>

                                    <option value="output" ${scheduledExecution.defaultTab == 'output' ?
                                                             'selected="selected"' :
                                                             ''}>
                                        <g:message code="execution.show.mode.Log.title"/>
                                    </option>
                                    <option value="html" ${scheduledExecution.defaultTab == 'html' ?
                                                           'selected="selected"' :
                                                           ''}>
                                        <g:message code="html"/>
                                    </option>
                                </select>
                            </label>
                        </div>
                    </div>

                </div>



            </div>

            <div class="col-xs-12 col-sm-3">

                <div class="btn-group pull-right">

                    <button type="submit"
                            name="_action_runJobNow"
                            id="execFormRunButton"
                        ${scheduledExecution.hasExecutionEnabled() ? '' : 'disabled'}
                            class=" btn btn-success  ">
                        <b class="fas fa-bug"  data-bind="visible: debug()"></b>
                        <g:message code="run.job.now"/>
                        <b class="glyphicon glyphicon-play"></b>
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div class="clearfix">
    </div>
</div>
